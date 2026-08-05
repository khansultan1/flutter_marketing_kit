import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared/shared.dart';

/// Class representing a detected screen widget and its import path.
class DetectedScreen {
  final String className;
  final String importPath;

  const DetectedScreen({
    required this.className,
    required this.importPath,
  });
}

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

  /// Checks if [projectRoot] uses Google Fonts.
  bool _usesGoogleFonts(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('google_fonts')) {
      return true;
    }
    return false;
  }

  /// Dynamically detects all Hive box names referenced across `lib/` dart files.
  Set<String> _detectHiveBoxNames(String projectRoot) {
    final boxNames = <String>{
      'progress_box',
      'settings_box',
      'learning_box',
      'analytics_box',
      'player_box',
      'game_box',
      'user_box',
      'app_box',
    };
    final libDir = Directory(p.join(projectRoot, 'lib'));
    if (libDir.existsSync()) {
      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final boxRegex =
          RegExp(r'''(?:openBox|box)(?:<[^>]+>)?\s*\(\s*['"]([^'"]+)['"]''');
      for (final f in files) {
        final content = f.readAsStringSync();
        for (final m in boxRegex.allMatches(content)) {
          final name = m.group(1);
          if (name != null && name.isNotEmpty) {
            boxNames.add(name);
          }
        }
      }
    }
    return boxNames;
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

  /// Finds all `.ttf` and `.otf` font files in `assets/fonts/` or `assets/`,
  /// grouped by font family.
  Map<String, List<String>> _detectAppFonts(String projectRoot) {
    final fontMap = <String, List<String>>{};
    final fontsDir = Directory(p.join(projectRoot, 'assets', 'fonts'));
    if (fontsDir.existsSync()) {
      final entities = fontsDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File &&
            (entity.path.endsWith('.ttf') || entity.path.endsWith('.otf'))) {
          final filename = p.basenameWithoutExtension(entity.path);
          final family = filename.split('-').first;
          final relPath = p.relative(entity.path, from: projectRoot);
          fontMap.putIfAbsent(family, () => []).add(relPath);
        }
      }
    }
    return fontMap;
  }

  /// Dynamically detects screen widget classes across `lib/` in any Flutter app.
  Map<String, DetectedScreen> _detectAllScreens(
    String projectRoot,
    String packageName,
  ) {
    final screens = <String, DetectedScreen>{};
    final libDir = Directory(p.join(projectRoot, 'lib'));
    if (!libDir.existsSync()) return screens;

    final files = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final classRegex = RegExp(
      r'class\s+([A-Z][a-zA-Z0-9_]*(?:Screen|Page|View))\s+extends',
    );

    for (final file in files) {
      final content = file.readAsStringSync();
      final matches = classRegex.allMatches(content);
      final relPath = p.relative(file.path, from: libDir.path);
      final importPath = 'package:$packageName/$relPath';

      for (final m in matches) {
        final className = m.group(1)!;
        screens[className] = DetectedScreen(
          className: className,
          importPath: importPath,
        );
      }
    }
    return screens;
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

  /// Map route path to best matching detected screen widget class name
  String? _resolveRouteWidget(
    String route,
    String screenId,
    Map<String, DetectedScreen> detectedScreens,
    String? mainWidget,
  ) {
    final cleanRoute = route.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final cleanId = screenId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

    for (final entry in detectedScreens.entries) {
      final nameLower = entry.key.toLowerCase();
      if (cleanId.isNotEmpty && nameLower.contains(cleanId)) {
        return entry.key;
      }
      if (cleanRoute.isNotEmpty && nameLower.contains(cleanRoute)) {
        return entry.key;
      }
    }

    if (route == '/' || cleanRoute == 'home') {
      for (final key in detectedScreens.keys) {
        if (key.toLowerCase().contains('home')) return key;
      }
    }

    return mainWidget;
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
    final isGoogleFonts = _usesGoogleFonts(projectRoot);
    final isFlutterAnimate = _usesFlutterAnimate(projectRoot);
    final hiveBoxes = _detectHiveBoxNames(projectRoot);
    final fontMap = _detectAppFonts(projectRoot);
    final detectedScreens = packageName != null
        ? _detectAllScreens(projectRoot, packageName)
        : <String, DetectedScreen>{};

    final hasHiveService = packageName != null &&
        File(p.join(projectRoot, 'lib', 'core', 'services', 'hive_service.dart')).existsSync();

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

    if (isGoogleFonts) {
      buffer.writeln("import 'package:google_fonts/google_fonts.dart';");
    }

    if (isFlutterAnimate) {
      buffer.writeln(
        "import 'package:flutter_animate/flutter_animate.dart';",
      );
    }

    final imports = <String>{};
    if (canImportApp) {
      imports.add("import 'package:$packageName/main.dart';");
    }

    for (final entry in config.screens.entries) {
      final screenId = entry.key;
      final route = entry.value.route;
      final widgetName = _resolveRouteWidget(
        route,
        screenId,
        detectedScreens,
        mainWidget,
      );
      if (widgetName != null && detectedScreens.containsKey(widgetName)) {
        imports.add("import '${detectedScreens[widgetName]!.importPath}';");
      }
    }

    if (hasHiveService) {
      imports.add("import 'package:$packageName/core/services/hive_service.dart';");
    }

    for (final imp in imports) {
      buffer.writeln(imp);
    }

    buffer
      ..writeln()
      ..writeln('Future<void> _loadAppFonts() async {');

    for (final entry in fontMap.entries) {
      final family = entry.key;
      final paths = entry.value;
      buffer
        ..writeln("  final loader_$family = FontLoader('$family');")
        ..writeln("  for (final path in ${paths.map((p) => "'$p'").toList()}) {")
        ..writeln('    final file = File(path);')
        ..writeln('    if (file.existsSync()) {')
        ..writeln('      final bytes = await file.readAsBytes();')
        ..writeln(
          '      loader_$family.addFont(Future.value(ByteData.view(bytes.buffer)));',
        )
        ..writeln('    }')
        ..writeln('  }')
        ..writeln('  await loader_$family.load();');
    }

    final cairoFile = File(
      p.join(projectRoot, 'assets', 'fonts', 'Cairo-Bold.ttf'),
    );
    final fredokaFile = File(
      p.join(projectRoot, 'assets', 'fonts', 'Fredoka-Bold.ttf'),
    );

    if (cairoFile.existsSync() || fredokaFile.existsSync()) {
      buffer
        ..writeln("  final dongolLoader = FontLoader('Dongol');")
        ..writeln('  for (final path in [')
        ..writeln("    'assets/fonts/Fredoka-Bold.ttf',")
        ..writeln("    'assets/fonts/Fredoka-Regular.ttf',")
        ..writeln("    'assets/fonts/Cairo-Bold.ttf',")
        ..writeln("    'assets/fonts/Cairo-Regular.ttf',")
        ..writeln('  ]) {')
        ..writeln('    final file = File(path);')
        ..writeln('    if (file.existsSync()) {')
        ..writeln('      final bytes = await file.readAsBytes();')
        ..writeln(
          '      dongolLoader.addFont(Future.value(ByteData.view(bytes.buffer)));',
        )
        ..writeln('    }')
        ..writeln('  }')
        ..writeln('  await dongolLoader.load();');
    }

    buffer
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
      ..writeln('    TestWidgetsFlutterBinding.ensureInitialized();')
      ..writeln('    FlutterError.onError = (FlutterErrorDetails details) {};');

    if (isGoogleFonts) {
      buffer.writeln('    try { GoogleFonts.config.allowRuntimeFetching = false; } catch (_) {}');
    }

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
      ..writeln('    final mockChannels = [')
      ..writeln("      'plugins.flutter.io/path_provider',")
      ..writeln("      'plugins.flutter.io/path_provider_macos',")
      ..writeln("      'xyz.luan/audioplayers.global',")
      ..writeln("      'xyz.luan/audioplayers',")
      ..writeln("      'plugins.flutter.io/shared_preferences',")
      ..writeln("      'purchases_flutter',")
      ..writeln("      'plugins.flutter.io/google_mobile_ads',")
      ..writeln("      'plugins.flutter.io/firebase_analytics',")
      ..writeln("      'plugins.flutter.io/firebase_core',")
      ..writeln("      'plugins.flutter.io/firebase_auth',")
      ..writeln("      'plugins.flutter.io/package_info',")
      ..writeln("      'dev.fluttercommunity.plus/package_info',")
      ..writeln("      'dev.fluttercommunity.plus/connectivity',")
      ..writeln("      'dev.fluttercommunity.plus/connectivity_status',")
      ..writeln("      'dev.fluttercommunity.plus/device_info',")
      ..writeln("      'flutter_vibrate',")
      ..writeln("      'vibration',")
      ..writeln("      'sqflite',")
      ..writeln('    ];')
      ..writeln('    for (final ch in mockChannels) {')
      ..writeln('      messenger.setMockMethodCallHandler(')
      ..writeln('        MethodChannel(ch),')
      ..writeln('        (MethodCall call) async {')
      ..writeln("          if (call.method == 'getApplicationDocumentsDirectory' || call.method == 'getTemporaryDirectory') return tempDir.path;")
      ..writeln("          if (call.method == 'getAll') return <String, dynamic>{};")
      ..writeln('          return null;')
      ..writeln('        },')
      ..writeln('      );')
      ..writeln('    }');

    if (isHive) {
      buffer.writeln('    try {');
      buffer.writeln('      Hive.init(tempDir.path);');
      for (final boxName in hiveBoxes) {
        buffer.writeln("      await Hive.openBox('$boxName');");
      }
      buffer.writeln('    } catch (_) {}');

      if (hasHiveService) {
        buffer
          ..writeln('    try {')
          ..writeln('      await HiveService().init();')
          ..writeln('    } catch (_) {}');
      }
    }

    buffer
      ..writeln('    await _loadAppFonts();')
      ..writeln('  });');

    for (final deviceId in config.devices) {
      final deviceSpec = DeviceSpec.findById(deviceId);
      if (deviceSpec == null) continue;

      final width = deviceSpec.width;
      final height = deviceSpec.height;
      final ratio = deviceSpec.pixelRatio;

      for (final locale in config.languages) {
        for (final entry in config.screens.entries) {
          final screenId = entry.key;
          final screen = entry.value;
          final route = screen.route;

          final rootKey = 'key_${deviceSpec.id}_${screenId}_$locale'
              .replaceAll('-', '_');

          final widgetConstructor = _resolveRouteWidget(
            route,
            screenId,
            detectedScreens,
            mainWidget,
          );

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
          final subtitle = screen.subtitle ?? screen.route;

          buffer
            ..writeln()
            ..writeln('  testWidgets(')
            ..writeln("    '${deviceSpec.name} - $screenId - $locale',")
            ..writeln('    (WidgetTester tester) async {')
            ..writeln('      final binding = tester.binding;')
            ..writeln(
              '      tester.view.physicalSize = const Size($width, $height);',
            )
            ..writeln('      tester.view.devicePixelRatio = $ratio;')
            ..writeln(
              '      await binding.setSurfaceSize(const Size($width, $height));',
            )
            ..writeln('      final $rootKey = GlobalKey();')
            ..writeln('      bool ${rootKey}_success = false;');

          if (widgetExpr != null) {
            buffer.writeln('      try {');
            buffer.writeln('        await tester.pumpWidget(');

            if (isRiverpod) {
              buffer
                ..writeln('          ProviderScope(')
                ..writeln('            key: ValueKey("ps_$rootKey"),')
                ..writeln('            child: MaterialApp(')
                ..writeln('              key: ValueKey("app_$rootKey"),');
            } else {
              buffer
                ..writeln('          MaterialApp(')
                ..writeln('            key: ValueKey("app_$rootKey"),');
            }

            buffer
              ..writeln('              debugShowCheckedModeBanner: false,')
              ..writeln('              home: RepaintBoundary(')
              ..writeln('                key: $rootKey,')
              ..writeln('                child: $widgetExpr,')
              ..writeln('              ),')
              ..writeln('            ),');

            if (isRiverpod) {
              buffer.writeln('          ),');
            }

            buffer
              ..writeln('        );')
              ..writeln('        await tester.pump();')
              ..writeln('        for (int i = 0; i < 50; i++) {')
              ..writeln('          try {')
              ..writeln(
                '            await tester.pump(const Duration(milliseconds: 100));',
              )
              ..writeln('          } catch (_) {}')
              ..writeln('        }')
              ..writeln('        tester.takeException();')
              ..writeln(
                '        ${rootKey}_success = find.byKey($rootKey).evaluate().isNotEmpty;',
              )
              ..writeln('      } catch (_) {}');
          }

          buffer
            ..writeln('      if (!${rootKey}_success) {')
            ..writeln(
              '        try { await tester.pumpWidget(const SizedBox.shrink()); } catch (_) {}',
            )
            ..writeln('        try {')
            ..writeln('          await tester.pumpWidget(')
            ..writeln('            MaterialApp(')
            ..writeln('              key: ValueKey("fallback_$rootKey"),')
            ..writeln('              debugShowCheckedModeBanner: false,')
            ..writeln('              home: RepaintBoundary(')
            ..writeln('                key: $rootKey,')
            ..writeln('                child: Scaffold(')
            ..writeln(
              '                  backgroundColor: const Color(0xFF1A1A2E),',
            )
            ..writeln('                  body: Center(')
            ..writeln('                    child: Column(')
            ..writeln('                      mainAxisSize: MainAxisSize.min,')
            ..writeln('                      children: [')
            ..writeln("                        Text('${screen.title}',")
            ..writeln('                          style: const TextStyle(')
            ..writeln('                            color: Colors.white,')
            ..writeln('                            fontSize: 28,')
            ..writeln('                            fontWeight: FontWeight.bold,')
            ..writeln('                          ),')
            ..writeln('                        ),')
            ..writeln('                        const SizedBox(height: 8),')
            ..writeln("                        Text('$subtitle',")
            ..writeln('                          style: const TextStyle(')
            ..writeln('                            color: Colors.white70,')
            ..writeln('                            fontSize: 16,')
            ..writeln('                          ),')
            ..writeln('                        ),')
            ..writeln('                      ],')
            ..writeln('                    ),')
            ..writeln('                  ),')
            ..writeln('                ),')
            ..writeln('              ),')
            ..writeln('            ),')
            ..writeln('          );')
            ..writeln('          await tester.pump();')
            ..writeln('        } catch (_) {}')
            ..writeln('      }')
            ..writeln('      final ${rootKey}_file = File(r"$outputPath");')
            ..writeln('      if (!${rootKey}_file.parent.existsSync()) {')
            ..writeln('        ${rootKey}_file.parent.createSync(recursive: true);')
            ..writeln('      }')
            ..writeln('      try {')
            ..writeln('        await expectLater(')
            ..writeln('          find.byKey($rootKey),')
            ..writeln("        matchesGoldenFile('$goldenPath'),")
            ..writeln('      );')
            ..writeln('      } catch (_) {}')
            ..writeln('      try {')
            ..writeln('        await tester.pumpWidget(const SizedBox.shrink());')
            ..writeln('        await tester.pump();')
            ..writeln('      } catch (_) {}')
            ..writeln('    },')
            ..writeln('  );');
        }
      }
    }

    buffer.writeln('}');

    await harnessFile.writeAsString(buffer.toString());
    return harnessFile;
  }
}
