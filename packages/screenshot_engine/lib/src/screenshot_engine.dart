import 'package:path/path.dart' as p;
import 'package:screenshot_engine/src/capture/driver_capture_strategy.dart';
import 'package:screenshot_engine/src/capture/screenshot_capture_strategy.dart';
import 'package:screenshot_engine/src/models/screenshot_options.dart';
import 'package:screenshot_engine/src/models/screenshot_result.dart';
import 'package:shared/shared.dart';

/// Primary orchestrator for app screenshot capture workflows.
class ScreenshotEngine {
  /// Creates a [ScreenshotEngine] with an optional capture strategy.
  const ScreenshotEngine({
    ScreenshotCaptureStrategy strategy = const DriverCaptureStrategy(),
  }) : _strategy = strategy;

  final ScreenshotCaptureStrategy _strategy;

  /// Strategy name being utilized by engine.
  String get strategyName => _strategy.name;

  /// Capture a single screenshot using the provided [options].
  Future<ScreenshotResult> captureSingle(ScreenshotOptions options) {
    return _strategy.capture(options);
  }

  /// Batch capture screenshots across all screens, devices, and languages.
  Future<List<ScreenshotResult>> captureBatch(MarketingConfig config) async {
    final results = <ScreenshotResult>[];

    for (final language in config.languages) {
      for (final deviceSpec in config.resolvedDevices) {
        for (final entry in config.screens.entries) {
          final screenSpec = entry.value;

          final fileName =
              '${deviceSpec.id}_${screenSpec.id}_$language.png';
          final outputPath = p.join(
            config.outputDirectory,
            'raw_screenshots',
            language,
            deviceSpec.id,
            fileName,
          );

          final options = ScreenshotOptions(
            screenSpec: screenSpec,
            deviceSpec: deviceSpec,
            outputFilePath: outputPath,
            locale: language,
            themeMode: config.theme == 'dark'
                ? ScreenshotThemeMode.dark
                : ScreenshotThemeMode.light,
          );

          final result = await captureSingle(options);
          results.add(result);
        }
      }
    }

    return results;
  }
}
