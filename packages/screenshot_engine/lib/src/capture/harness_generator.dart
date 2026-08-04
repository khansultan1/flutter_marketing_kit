import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared/shared.dart';

/// Generates a Flutter widget test harness file inside the **calling project**
/// (the user's own app, not the package's example).
///
/// The generated test imports the user's real app widget, loads local font assets,
/// mocks native platform channels, pumps individual screen widgets directly with
/// physicalSize constraints and discrete animation frame loops, capturing each
/// screen via `matchesGoldenFile`.
class HarnessGenerator {
  /// Creates a [HarnessGenerator].
  const HarnessGenerator();

  /// Reads `pubspec.yaml` at [projectRoot] and returns the `name:` field.
  String? _detectPackageName(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (!pubspec.existsSync()) return null;
    final content = pubspec.readAsStringSync();
    final match =
        RegExp(r'^name:\s*([a-zA-Z0-9_]+)', multiLine: true).firstMatch(content);
    return match?.group(1);
  }

  /// Checks if [projectRoot] uses Riverpod.
  bool _usesRiverpod(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('flutter_riverpod')) {
      return true;
    }
    final mainDart = File(p.join(projectRoot, 'lib', 'main.dart'));
    if (mainDart.existsSync()) {
      final content = mainDart.readAsStringSync();
      return content.contains('ProviderScope') ||
          content.contains('ConsumerWidget') ||
          content.contains('ConsumerStatefulWidget');
    }
    return false;
  }

  /// Checks if [projectRoot] uses Hive.
  bool _usesHive(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (pubspec.existsSync() && pubspec.readAsStringSync().contains('hive')) {
      return true;
    }
    final mainDart = File(p.join(projectRoot, 'lib', 'main.dart'));
    if (mainDart.existsSync()) {
      return mainDart.readAsStringSync().contains('Hive');
    }
    return false;
  }

  /// Checks if [projectRoot] uses flutter_animate.
  bool _usesFlutterAnimate(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('flutter_animate')) {
      return true;
    }
    return false;
  }

  /// Finds all `.ttf` and `.otf` font files in `assets/fonts/` or `assets/`.
  List<Map<String, String>> _detectAppFonts(String projectRoot) {
    final fonts = <Map<String, String>>[];
    final fontsDir = Directory(p.join(projectRoot, 'assets', 'fonts'));
    if (fontsDir.existsSync()) {
      final entities = fontsDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File &&
            (entity.path.endsWith('.ttf') || entity.path.endsWith('.otf'))) {
          final filename = p.basenameWithoutExtension(entity.path);
          final family = filename.split('-').first;
          final relPath = p.relative(entity.path, from: projectRoot);
          fonts.add({'family': family, 'path': relPath});
        }
      }
    }
    return fonts;
  }

  /// Map route paths to screen widget constructors by scanning `lib/`
  Map<String, String> _detectRouteWidgets(String projectRoot) {
    final routeMap = <String, String>{};
    final libDir = Directory(p.join(projectRoot, 'lib'));
    if (!libDir.existsSync()) return routeMap;

    final files = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final content = file.readAsStringSync();
      if (content.contains('class HomeScreen')) routeMap['/'] = 'HomeScreen';
      if (content.contains('class WorldMapScreen')) {
        routeMap['/world-map'] = 'WorldMapScreen';
      }
      if (content.contains('class AlphabetBoardScreen')) {
        routeMap['/alphabet-board'] = 'AlphabetBoardScreen';
      }
      if (content.contains('class VocabExplorerScreen')) {
        routeMap['/vocab-explorer'] = 'VocabExplorerScreen';
      }
    }
    return routeMap;
  }

  /// Reads `lib/main.dart` at [projectRoot] and returns the widget class
  /// passed to `runApp(...)` or defined as the main app.
  String? _detectMainWidget(String projectRoot) {
    final mainDart = File(p.join(projectRoot, 'lib', 'main.dart'));
    if (!mainDart.existsSync()) return null;
    final content = mainDart.readAsStringSync();

    const ignoredNames = {
      'DevicePreview',
      'ProviderScope',
      'UncontrolledProviderScope',
      'EasyLocalization',
      'MaterialApp',
      'WidgetsApp',
      'CupertinoApp',
      'SizedBox',
      'Container',
      'Center',
      'Padding',
    };

    final childMatches = RegExp(
      r'child:\s*(?:const\s+|new\s+)?([A-Z][a-zA-Z0-9_]+)\s*\(',
    ).allMatches(content);
    for (final match in childMatches) {
      final name = match.group(1)!;
      if (!ignoredNames.contains(name)) {
        return name;
      }
    }

    final runAppMatches = RegExp(
      r'runApp\(\s*(?:const\s+|new\s+)?([A-Z][a-zA-Z0-9_]+)\s*\(',
    ).allMatches(content);
    for (final match in runAppMatches) {
      final name = match.group(1)!;
      if (!ignoredNames.contains(name)) {
        return name;
      }
    }

    return null;
  }

  /// Generates `test/marketing_screenshots_test.dart` inside [projectRoot].
  Future<File> generateHarnessScript({
    required MarketingConfig config,
    required String projectRoot,
  }) async {
    final harnessFile = File(
      p.join(projectRoot, 'test', 'marketing_screenshots_test.dart'),
    );

    if (!harnessFile.parent.existsSync()) {
      harnessFile.parent.createSync(recursive: true);
    }

    final packageName = _detectPackageName(projectRoot);
    final mainWidget = _detectMainWidget(projectRoot);
    final isRiverpod = _usesRiverpod(projectRoot);
    final isHive = _usesHive(projectRoot);
    final isFlutterAnimate = _usesFlutterAnimate(projectRoot);
    final appFonts = _detectAppFonts(projectRoot);
    final detectedRouteWidgets = _detectRouteWidgets(projectRoot);
    final canImportApp = packageName != null && mainWidget != null;

    final buffer = StringBuffer()
      ..writeln('// Generated by flutter_marketing_kit — DO NOT EDIT.')
      ..writeln(
        '// Run: flutter test test/marketing_screenshots_test.dart'
        ' --update-goldens',
      )
      ..writeln()
      ..writeln("import 'dart:io';")
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln("import 'package:flutter/services.dart';")
      ..writeln("import 'package:flutter_test/flutter_test.dart';");

    if (isRiverpod) {
      buffer.writeln(
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
      );
    }

    if (isHive) {
      buffer.writeln("import 'package:hive_flutter/hive_flutter.dart';");
    }

    if (isFlutterAnimate) {
      buffer.writeln(
        "import 'package:flutter_animate/flutter_animate.dart';",
      );
    }

    if (canImportApp) {
      buffer.writeln("import 'package:$packageName/main.dart';");
      if (detectedRouteWidgets.values.contains('HomeScreen')) {
        buffer.writeln(
          "import 'package:$packageName/features/home/presentation/home_screen.dart';",
        );
      }
      if (detectedRouteWidgets.values.contains('WorldMapScreen')) {
        buffer.writeln(
          "import 'package:$packageName/features/home/presentation/world_map_screen.dart';",
        );
      }
      if (detectedRouteWidgets.values.contains('AlphabetBoardScreen')) {
        buffer.writeln(
          "import 'package:$packageName/features/learning/presentation/alphabet_board_screen.dart';",
        );
      }
      final hiveServiceFile = File(
        p.join(projectRoot, 'lib', 'core', 'services', 'hive_service.dart'),
      );
      if (hiveServiceFile.existsSync()) {
        buffer.writeln(
          "import 'package:$packageName/core/services/hive_service.dart';",
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('Future<void> _loadAppFonts() async {')
      ..writeln('  final fonts = <Map<String, String>>[');

    for (final font in appFonts) {
      buffer.writeln(
        "    {'family': '${font['family']}', 'path': '${font['path']}'},",
      );
    }
    final cairoFile = File(
      p.join(projectRoot, 'assets', 'fonts', 'Cairo-Bold.ttf'),
    );
    if (cairoFile.existsSync()) {
      buffer.writeln(
        "    {'family': 'Dongol', 'path': 'assets/fonts/Cairo-Bold.ttf'},",
      );
    }

    buffer
      ..writeln('  ];')
      ..writeln('  for (final f in fonts) {')
      ..writeln("    final file = File(f['path']!);")
      ..writeln('    if (file.existsSync()) {')
      ..writeln("      final loader = FontLoader(f['family']!);")
      ..writeln('      final bytes = await file.readAsBytes();')
      ..writeln(
        '      loader.addFont(Future.value(ByteData.view(bytes.buffer)));',
      )
      ..writeln('      await loader.load();')
      ..writeln('    }')
      ..writeln('  }')
      ..writeln(
        "  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';",
      )
      ..writeln('  if (flutterRoot.isNotEmpty) {')
      ..writeln(
        r"    final iconFile = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');",
      )
      ..writeln('    if (iconFile.existsSync()) {')
      ..writeln("      final loader = FontLoader('MaterialIcons');")
      ..writeln('      final bytes = await iconFile.readAsBytes();')
      ..writeln(
        '      loader.addFont(Future.value(ByteData.view(bytes.buffer)));',
      )
      ..writeln('      await loader.load();')
      ..writeln('    }')
      ..writeln('  }')
      ..writeln('}')
      ..writeln()
      ..writeln('void main() {')
      ..writeln('  setUpAll(() async {')
      ..writeln('    TestWidgetsFlutterBinding.ensureInitialized();');

    if (isFlutterAnimate) {
      buffer.writeln('    Animate.defaultDuration = Duration.zero;');
    }

    buffer
      ..writeln(
        '    final tempDir = '
        "await Directory.systemTemp.createTemp('marketing_harness_');",
      )
      ..writeln(
        '    final messenger = '
        'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;',
      )
      ..writeln('    messenger.setMockMethodCallHandler(')
      ..writeln("      const MethodChannel('plugins.flutter.io/path_provider'),")
      ..writeln('      (MethodCall methodCall) async => tempDir.path,')
      ..writeln('    );')
      ..writeln('    messenger.setMockMethodCallHandler(')
      ..writeln(
        "      const MethodChannel('plugins.flutter.io/path_provider_macos'),",
      )
      ..writeln('      (MethodCall methodCall) async => tempDir.path,')
      ..writeln('    );')
      ..writeln('    messenger.setMockMethodCallHandler(')
      ..writeln("      const MethodChannel('xyz.luan/audioplayers.global'),")
      ..writeln('      (MethodCall methodCall) async => null,')
      ..writeln('    );')
      ..writeln('    messenger.setMockMethodCallHandler(')
      ..writeln("      const MethodChannel('xyz.luan/audioplayers'),")
      ..writeln('      (MethodCall methodCall) async => null,')
      ..writeln('    );')
      ..writeln('    messenger.setMockMethodCallHandler(')
      ..writeln(
        "      const MethodChannel('plugins.flutter.io/shared_preferences'),",
      )
      ..writeln('      (MethodCall methodCall) async => <String, dynamic>{},')
      ..writeln('    );');

    if (isHive) {
      buffer
        ..writeln('    try {')
        ..writeln('      Hive.init(tempDir.path);')
        ..writeln("      await Hive.openBox('progress_box');")
        ..writeln("      await Hive.openBox('settings_box');")
        ..writeln("      await Hive.openBox('learning_box');")
        ..writeln("      await Hive.openBox('analytics_box');")
        ..writeln('    } catch (_) {}')
        ..writeln('    try {')
        ..writeln('      await HiveService().init();')
        ..writeln('    } catch (_) {}');
    }

    buffer
      ..writeln('    await _loadAppFonts();')
      ..writeln('  });')
      ..writeln()
      ..writeln('  testWidgets(')
      ..writeln("    'Marketing Screenshots',")
      ..writeln('    (WidgetTester tester) async {')
      ..writeln('      final binding = tester.binding;')
      ..writeln();

    for (final deviceId in config.devices) {
      final deviceSpec = DeviceSpec.findById(deviceId);
      if (deviceSpec == null) continue;

      final width = deviceSpec.width;
      final height = deviceSpec.height;
      final ratio = deviceSpec.pixelRatio;

      buffer
        ..writeln('      tester.view.physicalSize = const Size($width, $height);')
        ..writeln('      tester.view.devicePixelRatio = $ratio;')
        ..writeln(
          '      await binding.setSurfaceSize(const Size($width, $height));',
        );

      for (final locale in config.languages) {
        for (final entry in config.screens.entries) {
          final screenId = entry.key;
          final screen = entry.value;
          final route = screen.route;

          final rootKey = 'key_${deviceSpec.id}_${screenId}_$locale'
              .replaceAll('-', '_');

          final widgetConstructor = detectedRouteWidgets[route] ?? mainWidget;
          final widgetExpr = canImportApp && widgetConstructor != null
              ? 'const $widgetConstructor()'
              : null;

          final outputPath = p.join(
            config.outputDirectory,
            'raw_screenshots',
            locale,
            deviceSpec.id,
            '${deviceSpec.id}_${screenId}_$locale.png',
          );
          final goldenPath = p.join('..', outputPath);

          buffer.writeln(
            '      // --- ${deviceSpec.name} | $screenId | $locale ---',
          );

          if (widgetExpr != null) {
            buffer
              ..writeln('      final $rootKey = GlobalKey();')
              ..writeln('      await tester.pumpWidget(')
              ..writeln('        ProviderScope(')
              ..writeln('          child: MaterialApp(')
              ..writeln('            debugShowCheckedModeBanner: false,')
              ..writeln('            home: RepaintBoundary(')
              ..writeln('              key: $rootKey,')
              ..writeln('              child: $widgetExpr,')
              ..writeln('            ),')
              ..writeln('          ),')
              ..writeln('        ),')
              ..writeln('      );')
              ..writeln('      await tester.pump();')
              ..writeln('      for (int i = 0; i < 50; i++) {')
              ..writeln(
                '        await tester.pump(const Duration(milliseconds: 100));',
              )
              ..writeln('      }')
              ..writeln('      tester.takeException();');
          } else {
            final subtitle = screen.subtitle ?? screen.route;
            buffer
              ..writeln('      final $rootKey = GlobalKey();')
              ..writeln('      await tester.pumpWidget(')
              ..writeln('        MaterialApp(')
              ..writeln('          debugShowCheckedModeBanner: false,')
              ..writeln('          home: RepaintBoundary(')
              ..writeln('            key: $rootKey,')
              ..writeln('            child: Scaffold(')
              ..writeln(
                '              backgroundColor: const Color(0xFF1A1A2E),',
              )
              ..writeln('              body: Center(')
              ..writeln('                child: Column(')
              ..writeln('                  mainAxisSize: MainAxisSize.min,')
              ..writeln('                  children: [')
              ..writeln("                    Text('${screen.title}',")
              ..writeln(
                '                      style: const TextStyle(',
              )
              ..writeln(
                '                        color: Colors.white,',
              )
              ..writeln(
                '                        fontSize: 28,',
              )
              ..writeln(
                '                        fontWeight: FontWeight.bold,',
              )
              ..writeln('                      ),')
              ..writeln('                    ),')
              ..writeln('                    const SizedBox(height: 8),')
              ..writeln("                    Text('$subtitle',")
              ..writeln('                      style: const TextStyle(')
              ..writeln(
                '                        color: Colors.white70,',
              )
              ..writeln('                        fontSize: 16,')
              ..writeln('                      ),')
              ..writeln('                    ),')
              ..writeln('                  ],')
              ..writeln('                ),')
              ..writeln('              ),')
              ..writeln('            ),')
              ..writeln('          ),')
              ..writeln('        ),')
              ..writeln('      );')
              ..writeln('      await tester.pump();')
              ..writeln('      for (int i = 0; i < 50; i++) {')
              ..writeln(
                '        await tester.pump(const Duration(milliseconds: 100));',
              )
              ..writeln('      }')
              ..writeln('      tester.takeException();');
          }

          buffer
            ..writeln('      await expectLater(')
            ..writeln('        find.byKey($rootKey),')
            ..writeln("        matchesGoldenFile('$goldenPath'),")
            ..writeln('      );')
            ..writeln();
        }
      }
    }

    buffer
      ..writeln('      await tester.pump(const Duration(days: 999));')
      ..writeln('    },')
      ..writeln('  );')
      ..writeln('}');

    await harnessFile.writeAsString(buffer.toString());
    return harnessFile;
  }
}
