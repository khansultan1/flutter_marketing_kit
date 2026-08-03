import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:config_engine/config_engine.dart';
import 'package:device_frame_engine/device_frame_engine.dart';
import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:path/path.dart' as p;

/// CLI Command to frame raw screenshots inside device mockups.
class FramesCommand extends Command<int> {
  /// Creates an instance of [FramesCommand].
  FramesCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      defaultsTo: 'playstore_assets.yaml',
      help: 'Path to configuration YAML file.',
    );
  }

  @override
  String get name => 'frames';

  @override
  String get description =>
      'Frame captured screenshots with SVG device hardware mockups.';

  @override
  Future<int> run() async {
    final configPath =
        argResults?['config'] as String? ?? 'playstore_assets.yaml';
    final configFile = File(p.canonicalize(configPath));

    if (!configFile.existsSync()) {
      stderr.writeln('❌ Configuration file missing: ${configFile.path}');
      return 1;
    }

    const parser = YamlConfigParser();
    final config = parser.parse(await configFile.readAsString());

    stdout.writeln('🖼️ Framing screenshots with device mockups...');

    const renderer = DeviceFrameRenderer();
    const processor = ImageProcessor();
    var frameCount = 0;

    for (final language in config.languages) {
      for (final deviceSpec in config.resolvedDevices) {
        for (final screenSpec in config.screens.values) {
          final screenshotFile = File(
            p.join(
              config.outputDirectory,
              'raw_screenshots',
              language,
              deviceSpec.id,
              '${deviceSpec.id}_${screenSpec.id}_$language.png',
            ),
          );

          if (screenshotFile.existsSync()) {
            final rawBytes = await screenshotFile.readAsBytes();
            final decoded = img.decodePng(rawBytes);

            if (decoded != null) {
              final framed = renderer.frameScreenshot(
                screenshot: decoded,
                deviceSpec: deviceSpec,
              );

              final framedPath = p.join(
                config.outputDirectory,
                'framed_screenshots',
                language,
                deviceSpec.id,
                'framed_${screenSpec.id}.png',
              );

              final framedFile = File(framedPath);
              if (!framedFile.parent.existsSync()) {
                framedFile.parent.createSync(recursive: true);
              }

              final pngBytes = processor.encode(framed);
              await framedFile.writeAsBytes(pngBytes);
              frameCount++;
            }
          }
        }
      }
    }

    stdout.writeln('✅ Composited $frameCount device frames successfully.');
    return 0;
  }
}
