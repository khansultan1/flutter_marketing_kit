import 'dart:io';

import 'package:screenshot_engine/screenshot_engine.dart';
import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('ScreenshotOptions tests', () {
    const screen = ScreenSpec(
      id: 'home',
      route: '/',
      title: 'Home Screen',
    );
    final pixelSpec = DeviceSpec.findById('pixel9')!;

    test('calculates correct dimensions for portrait and high DPI', () {
      final options = ScreenshotOptions(
        screenSpec: screen,
        deviceSpec: pixelSpec,
        outputFilePath: 'test_out.png',
      );

      expect(options.captureWidth, equals(1080 * 3));
      expect(options.captureHeight, equals(2424 * 3));
    });

    test('calculates correct dimensions for landscape orientation', () {
      final options = ScreenshotOptions(
        screenSpec: screen,
        deviceSpec: pixelSpec,
        outputFilePath: 'test_out.png',
        orientation: ScreenshotOrientation.landscape,
        highDpi: false,
      );

      expect(options.captureWidth, equals(2424));
      expect(options.captureHeight, equals(1080));
    });
  });

  group('HarnessGenerator tests', () {
    test('generates valid Flutter WidgetTester harness test file', () async {
      const generator = HarnessGenerator();
      const config = MarketingConfig(
        appName: 'TestApp',
        packageName: 'com.example.test',
        outputDirectory: 'test_marketing_out',
        theme: 'modern',
        template: 'gaming',
        primaryColor: '#5E5CE6',
        accentColor: '#00C2FF',
        devices: ['pixel9'],
        languages: ['en'],
        screens: {
          'home': ScreenSpec(id: 'home', route: '/', title: 'Home'),
        },
      );

      final file = await generator.generateHarnessScript(
        config: config,
        projectRoot: Directory.systemTemp.createTempSync('harness_test').path,
      );

      expect(file.existsSync(), isTrue);
      final content = await file.readAsString();
      expect(content, contains('WidgetTester tester'));
      expect(content, contains('setSurfaceSize'));
    });
  });

  group('ScreenshotEngine tests', () {
    test('captures single screenshot successfully', () async {
      const engine = ScreenshotEngine();
      const screen = ScreenSpec(
        id: 'home',
        route: '/',
        title: 'Home Screen',
      );
      final pixelSpec = DeviceSpec.findById('pixel9')!;
      final testFile = File('test_screenshots/single.png');

      final options = ScreenshotOptions(
        screenSpec: screen,
        deviceSpec: pixelSpec,
        outputFilePath: testFile.path,
      );

      final result = await engine.captureSingle(options);

      expect(result.isSuccess, isTrue);
      expect(result.filePath, endsWith('test_screenshots/single.png'));
      expect(testFile.existsSync(), isTrue);

      if (testFile.parent.existsSync()) {
        testFile.parent.deleteSync(recursive: true);
      }
    });

    test('executes batch capture across devices and languages', () async {
      const engine = ScreenshotEngine();
      const config = MarketingConfig(
        appName: 'TestApp',
        packageName: 'com.example.test',
        outputDirectory: 'test_marketing_out',
        theme: 'modern',
        template: 'gaming',
        primaryColor: '#5E5CE6',
        accentColor: '#00C2FF',
        devices: ['pixel9', 'iphone16'],
        languages: ['en'],
        screens: {
          'home': ScreenSpec(id: 'home', route: '/', title: 'Home'),
        },
      );

      final results = await engine.captureBatch(config);
      expect(results.length, equals(2));
      for (final res in results) {
        expect(res.isSuccess, isTrue);
      }

      final outDir = Directory('test_marketing_out');
      if (outDir.existsSync()) {
        outDir.deleteSync(recursive: true);
      }
    });
  });
}
