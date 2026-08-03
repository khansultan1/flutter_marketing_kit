import 'dart:io';

import 'package:ai_engine/ai_engine.dart';
import 'package:args/command_runner.dart';
import 'package:asset_export_engine/asset_export_engine.dart';
import 'package:config_engine/config_engine.dart';
import 'package:device_frame_engine/device_frame_engine.dart';
import 'package:feature_graphic_engine/feature_graphic_engine.dart';
import 'package:github_engine/github_engine.dart';
import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:path/path.dart' as p;
import 'package:screenshot_engine/screenshot_engine.dart';
import 'package:shared/shared.dart';
import 'package:social_engine/social_engine.dart';
import 'package:store_engine/store_engine.dart';
import 'package:template_engine/template_engine.dart';

/// CLI Command to generate all marketing assets in one step.
class GenerateCommand extends Command<int> {
  /// Creates an instance of [GenerateCommand].
  GenerateCommand() {
    argParser
      ..addOption(
        'config',
        abbr: 'c',
        defaultsTo: 'playstore_assets.yaml',
        help: 'Path to configuration YAML file.',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        help: 'Enable detailed logging output.',
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description =>
      'Generate all app marketing assets (Screenshots, Frames, Store, Social).';

  @override
  Future<int> run() async {
    final configPath =
        argResults?['config'] as String? ?? 'playstore_assets.yaml';
    final configFile = File(p.canonicalize(configPath));

    if (!configFile.existsSync()) {
      stderr.writeln(
        '❌ Configuration file missing: ${configFile.path}\n'
        '   Run `dart run flutter_marketing_kit init` to create one.',
      );
      return 1;
    }

    stdout.writeln('⚙️  Loading configuration from ${configFile.path}...');
    const parser = YamlConfigParser();
    late MarketingConfig config;

    try {
      config = parser.parse(await configFile.readAsString());
    } on MarketingKitException catch (e) {
      stderr.writeln('❌ ${e.message}');
      if (e.suggestion != null) {
        stderr.writeln('💡 Suggestion: ${e.suggestion}');
      }
      return 1;
    }

    stdout
      ..writeln('🚀 Starting asset generation for "${config.appName}"...')
      ..writeln('📱 Target Devices: ${config.devices.join(", ")}')
      ..writeln('🌐 Languages: ${config.languages.join(", ")}')
      ..writeln('🎨 Theme: ${config.theme} (${config.primaryColor})')
      ..writeln('📁 Output Directory: ${config.outputDirectory}/');

    const screenshotEngine = ScreenshotEngine();
    const frameRenderer = DeviceFrameRenderer();
    const processor = ImageProcessor();
    const featureGraphicGen = FeatureGraphicGenerator();
    const storeGen = StoreAssetGenerator();
    const socialGen = SocialAssetGenerator();
    const aiEngine = AiEngine();
    const readmeGen = ReadmeGenerator();
    const exporter = AssetExporter();

    // 1. Screenshots
    final screenCount = config.screens.length * config.devices.length;
    stdout
      ..writeln('\n📸 Step 1/6: Capturing raw screenshots...')
      ..writeln('   Captured $screenCount screens.');
    final screenshotResults = await screenshotEngine.captureBatch(config);

    // 2. Framing
    stdout.writeln('\n🖼️ Step 2/6: Rendering SVG device hardware mockups...');
    var frameCount = 0;
    for (final res in screenshotResults) {
      if (res.isSuccess && res.filePath != null) {
        final rawBytes = await File(res.filePath!).readAsBytes();
        final decoded = img.decodePng(rawBytes);
        if (decoded != null) {
          final framed = frameRenderer.frameScreenshot(
            screenshot: decoded,
            deviceSpec: res.options.deviceSpec,
          );
          final framedPath = p.join(
            config.outputDirectory,
            'framed_screenshots',
            res.options.locale,
            res.options.deviceSpec.id,
            'framed_${res.options.screenSpec.id}.png',
          );
          final outFile = File(framedPath);
          if (!outFile.parent.existsSync()) {
            outFile.parent.createSync(recursive: true);
          }
          await outFile.writeAsBytes(processor.encode(framed));
          frameCount++;
        }
      }
    }
    stdout.writeln('   Composited $frameCount device frames.');

    // 3. Feature Graphics
    final style = TemplateStyle.findByName(config.theme);
    final featureGraphic = featureGraphicGen.generateFeatureGraphic(
      appName: config.appName,
      subtitle: config.screens.values.firstOrNull?.title ?? 'Marketing App',
      style: style,
    );
    final fgFile = File(
      p.join(
        config.outputDirectory,
        'store_assets',
        'feature_graphic_1024x500.png',
      ),
    );
    if (!fgFile.parent.existsSync()) {
      fgFile.parent.createSync(recursive: true);
    }
    await fgFile.writeAsBytes(processor.encode(featureGraphic));
    stdout
      ..writeln('\n🎨 Step 3/6: Generating Play Store feature graphics...')
      ..writeln('   Generated 1024x500 feature graphic.');

    // 4. Store & Social Assets
    final playDims =
        StoreAssetGenerator.storeDimensions[StorePlatform.googlePlay]!;
    for (final dim in playDims) {
      final formatted = storeGen.formatStoreAsset(featureGraphic, dim);
      final fileName = '${dim.name.replaceAll(' ', '_')}.png';
      final file = File(
        p.join(
          config.outputDirectory,
          'store_assets',
          'google_play',
          fileName,
        ),
      );
      if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
      await file.writeAsBytes(processor.encode(formatted));
    }

    for (final dim in SocialTargetDimension.presets) {
      final formatted = socialGen.formatSocialAsset(featureGraphic, dim);
      final fileName = '${dim.name.replaceAll(' ', '_')}.png';
      final file = File(
        p.join(
          config.outputDirectory,
          'social_assets',
          dim.platform.name,
          fileName,
        ),
      );
      if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
      await file.writeAsBytes(processor.encode(formatted));
    }
    stdout
      ..writeln('\n🌐 Step 4/6: Formatting Store & Social graphics...')
      ..writeln('   Generated store & social media graphics.');

    // 5. AI Marketing Copy & README
    final copy = await aiEngine.generateCopy(
      appName: config.appName,
      apiKey: config.aiApiKey,
      providerKey: config.aiProvider,
    );
    final copyFile = File(
      p.join(
        config.outputDirectory,
        'copywriting',
        'store_descriptions.txt',
      ),
    );
    if (!copyFile.parent.existsSync()) {
      copyFile.parent.createSync(recursive: true);
    }
    await copyFile.writeAsString(
      'Short Description:\n${copy.shortDescription}\n\n'
      'Full Description:\n${copy.fullDescription}\n\n'
      'Keywords:\n${copy.keywords.join(", ")}\n',
    );

    final readmeContent = readmeGen.generateReadme(config);
    final readmeFile = File(p.join(config.outputDirectory, 'README.md'));
    await readmeFile.writeAsString(readmeContent);
    stdout
      ..writeln('\n📝 Step 5/6: Generating ASO Copy & README...')
      ..writeln('   Generated copy & README documentation.');

    // 6. Archive Exporter
    final zipFile = await exporter.compressToZip(
      sourceDir: Directory(config.outputDirectory),
      zipPath: p.join(config.outputDirectory, 'marketing_assets_bundle.zip'),
    );
    stdout
      ..writeln('\n📦 Step 6/6: Archiving export directory to ZIP...')
      ..writeln('   Created archive: ${zipFile.path}')
      ..writeln('\n✨ All marketing assets generated successfully!');
    return 0;
  }
}
