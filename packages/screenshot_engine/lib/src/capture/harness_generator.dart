import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared/shared.dart';

/// Generates a Flutter widget test harness file inside the **calling project**
/// (the user's own app, not the package's example).
///
/// The generated test imports the user's real app widget, navigates to the
/// configured routes, and captures each screen via `matchesGoldenFile`.
/// Running it with `flutter test --update-goldens` produces real screenshots.
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

    // Pattern 1: child: MyApp() inside ProviderScope / DevicePreview wrapper
    final childMatches = RegExp(
      r'child:\s*(?:const\s+|new\s+)?([A-Z][a-zA-Z0-9_]+)\s*\(',
    ).allMatches(content);
    for (final match in childMatches) {
      final name = match.group(1)!;
      if (!ignoredNames.contains(name)) {
        return name;
      }
    }

    // Pattern 2: builder: (_) => MyApp() inside a wrapper
    final builderMatches = RegExp(
      r'builder:\s*\([^)]*\)\s*=>\s*(?:const\s+|new\s+)?([A-Z][a-zA-Z0-9_]+)\s*\(',
    ).allMatches(content);
    for (final match in builderMatches) {
      final name = match.group(1)!;
      if (!ignoredNames.contains(name)) {
        return name;
      }
    }

    // Pattern 3: runApp(const MyApp()); or runApp(MyApp());
    final runAppMatches = RegExp(
      r'runApp\(\s*(?:const\s+|new\s+)?([A-Z][a-zA-Z0-9_]+)\s*\(',
    ).allMatches(content);
    for (final match in runAppMatches) {
      final name = match.group(1)!;
      if (!ignoredNames.contains(name)) {
        return name;
      }
    }

    // Pattern 4: class MyApp extends StatelessWidget / StatefulWidget / ConsumerWidget
    final classMatches = RegExp(
      r'class\s+([A-Z][a-zA-Z0-9_]+)\s+extends\s+(?:StatelessWidget|StatefulWidget|ConsumerWidget|HookConsumerWidget|ConsumerStatefulWidget|Widget)',
    ).allMatches(content);
    for (final match in classMatches) {
      final name = match.group(1)!;
      if (!ignoredNames.contains(name)) {
        return name;
      }
    }

    return null;
  }

  /// Generates `test/marketing_screenshots_test.dart` inside [projectRoot].
  ///
  /// Run the generated file with:
  /// ```dart
  /// flutter test test/marketing_screenshots_test.dart --update-goldens
  /// ```
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
    final canImportApp = packageName != null && mainWidget != null;

    final routerFiles = [
      p.join(projectRoot, 'lib', 'core', 'router', 'app_router.dart'),
      p.join(projectRoot, 'lib', 'router', 'app_router.dart'),
      p.join(projectRoot, 'lib', 'app_router.dart'),
      p.join(projectRoot, 'lib', 'router.dart'),
    ];
    String? detectedAppRouterImport;
    for (final rf in routerFiles) {
      if (File(rf).existsSync() && packageName != null) {
        final rel = p.relative(rf, from: p.join(projectRoot, 'lib'));
        detectedAppRouterImport = "import 'package:$packageName/$rel';";
        break;
      }
    }

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

    if (canImportApp) {
      buffer.writeln("import 'package:$packageName/main.dart';");
      if (detectedAppRouterImport != null) {
        buffer.writeln(detectedAppRouterImport);
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
      ..writeln('void main() {')
      ..writeln('  setUpAll(() async {')
      ..writeln('    TestWidgetsFlutterBinding.ensureInitialized();')
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

      for (final locale in config.languages) {
        for (final entry in config.screens.entries) {
          final screenId = entry.key;
          final screen = entry.value;

          final outputPath = p.join(
            config.outputDirectory,
            'raw_screenshots',
            locale,
            deviceSpec.id,
            '${deviceSpec.id}_${screenId}_$locale.png',
          );

          final goldenPath = p.join('..', outputPath);
          final keyName = 'key_${deviceSpec.id}_${screenId}_$locale'
              .replaceAll('-', '_');

          buffer
            ..writeln(
              // ignore: missing_whitespace_between_adjacent_strings
              '      // ---'
              ' ${deviceSpec.name} | $screenId | $locale ---',
            )
            ..writeln(
              // ignore: missing_whitespace_between_adjacent_strings
              '      await binding.setSurfaceSize('
              'const Size($width, $height));',
            )
            ..writeln('      tester.view.devicePixelRatio = $ratio;')
            ..writeln('      final $keyName = GlobalKey();');

          if (canImportApp) {
            final appWidget = isRiverpod
                ? 'ProviderScope(child: $mainWidget())'
                : '$mainWidget()';

            buffer
              ..writeln('      await tester.pumpWidget(')
              ..writeln('        RepaintBoundary(')
              ..writeln('          key: $keyName,')
              ..writeln('          child: const $appWidget,')
              ..writeln('        ),')
              ..writeln('      );')
              ..writeln('      await tester.pump();')
              ..writeln(
                '      await tester.pump(const Duration(milliseconds: 500));',
              )
              ..writeln('      tester.takeException();');

            if (screen.route != '/') {
              buffer
                ..writeln('      try {')
                ..writeln(
                  // ignore: missing_whitespace_between_adjacent_strings, lines_longer_than_80_chars
                  '        final dynamic routerObj = (find.byType(Router, skipOffstage: false).evaluate().first.widget as Router).routerDelegate;',
                )
                ..writeln("        routerObj.go('${screen.route}');")
                ..writeln('      } catch (_) {')
                ..writeln('        try {');

              if (detectedAppRouterImport != null) {
                buffer.writeln(
                  "          AppRouter.router.go('${screen.route}');",
                );
              } else {
                buffer
                  ..writeln(
                    // ignore: missing_whitespace_between_adjacent_strings
                    '          final navState = tester.state<NavigatorState>'
                    '(find.byType(Navigator, skipOffstage: false));',
                  )
                  ..writeln("          navState.pushNamed('${screen.route}');");
              }

              buffer
                ..writeln('        } catch (e) {')
                ..writeln(
                  "          debugPrint('Could not navigate to "
                  "${screen.route}: \$e');",
                )
                ..writeln('        }')
                ..writeln('      }')
                ..writeln('      await tester.pump();')
                ..writeln(
                  '      await tester.pump(const Duration(milliseconds: 500));',
                )
                ..writeln('      tester.takeException();');
            }
          } else {
            final subtitle = screen.subtitle ?? screen.route;
            buffer
              ..writeln('      await tester.pumpWidget(')
              ..writeln('        MaterialApp(')
              ..writeln('          debugShowCheckedModeBanner: false,')
              ..writeln('          home: RepaintBoundary(')
              ..writeln('            key: $keyName,')
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
              ..writeln(
                '      await tester.pump(const Duration(milliseconds: 500));',
              )
              ..writeln('      tester.takeException();');
          }

          buffer
            ..writeln('      await expectLater(')
            ..writeln('        find.byKey($keyName),')
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
