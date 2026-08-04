import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:screenshot_engine/src/capture/driver_capture_strategy.dart';
import 'package:screenshot_engine/src/capture/harness_generator.dart';
import 'package:screenshot_engine/src/models/screenshot_options.dart';
import 'package:screenshot_engine/src/models/screenshot_result.dart';
import 'package:shared/shared.dart';

/// Golden test capture strategy adapter utilizing headless Flutter
/// WidgetTester.
class GoldenCaptureStrategy extends DriverCaptureStrategy {
  /// Creates a [GoldenCaptureStrategy].
  const GoldenCaptureStrategy();

  @override
  String get name => 'GoldenTestCaptureStrategy';

  /// Execute golden harness capture across config.
  Future<List<ScreenshotResult>> captureWithHarness(
    MarketingConfig config, {
    String projectRoot = '.',
  }) async {
    const generator = HarnessGenerator();

    try {
      final harnessFile = await generator.generateHarnessScript(
        config: config,
        projectRoot: projectRoot,
      );

      final processResult = await Process.run(
        'flutter',
        [
          'test',
          '--update-goldens',
          p.relative(harnessFile.path, from: projectRoot),
        ],
        workingDirectory: projectRoot,
      );

      if (processResult.exitCode == 0) {
        final results = <ScreenshotResult>[];
        for (final lang in config.languages) {
          for (final deviceId in config.devices) {
            final deviceSpec = DeviceSpec.findById(deviceId);
            if (deviceSpec != null) {
              for (final entry in config.screens.entries) {
                final screenSpec = entry.value;
                final fileName = '${deviceSpec.id}_${entry.key}_$lang.png';
                final filePath = p.canonicalize(
                  p.join(
                    config.outputDirectory,
                    'raw_screenshots',
                    lang,
                    deviceSpec.id,
                    fileName,
                  ),
                );

                final options = ScreenshotOptions(
                  screenSpec: screenSpec,
                  deviceSpec: deviceSpec,
                  outputFilePath: filePath,
                  locale: lang,
                );

                results.add(
                  ScreenshotResult.success(
                    options: options,
                    filePath: filePath,
                    captureDuration: Duration.zero,
                  ),
                );
              }
            }
          }
        }
        return results;
      }
    } catch (_) {
      // Fallback cleanly if flutter executable is not present
    }

    return [];
  }
}
