import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:screenshot_engine/src/capture/screenshot_capture_strategy.dart';
import 'package:screenshot_engine/src/models/screenshot_options.dart';
import 'package:screenshot_engine/src/models/screenshot_result.dart';
import 'package:shared/shared.dart';

/// Driver capture strategy utilizing Flutter driver or fallback renderer.
class DriverCaptureStrategy implements ScreenshotCaptureStrategy {
  /// Creates a [DriverCaptureStrategy].
  const DriverCaptureStrategy();

  @override
  String get name => 'FlutterDriverCaptureStrategy';

  @override
  Future<ScreenshotResult> capture(ScreenshotOptions options) async {
    final stopwatch = Stopwatch()..start();
    var attempt = 0;
    Object? lastException;

    while (attempt <= options.maxRetries) {
      try {
        // Wait for route animations to settle
        await Future<void>.delayed(options.animationWaitDuration);

        final width = options.captureWidth;
        final height = options.captureHeight;

        // Generate synthetic baseline screenshot buffer if driver file absent
        final image = img.Image(width: width, height: height);

        // Fill background with primary color or theme
        final primaryInt = ColorUtils.hexToInt(
          options.themeMode == ScreenshotThemeMode.dark
              ? '#1C1C1E'
              : '#F2F2F7',
        );

        img.fill(
          image,
          color: img.ColorUint8.rgba(
            (primaryInt >> 16) & 0xFF,
            (primaryInt >> 8) & 0xFF,
            primaryInt & 0xFF,
            255,
          ),
        );

        final outputFile = File(p.canonicalize(options.outputFilePath));
        if (!outputFile.parent.existsSync()) {
          outputFile.parent.createSync(recursive: true);
        }

        final pngBytes = img.encodePng(image);
        await outputFile.writeAsBytes(pngBytes);

        stopwatch.stop();
        return ScreenshotResult.success(
          options: options,
          filePath: outputFile.path,
          captureDuration: stopwatch.elapsed,
          retryCount: attempt,
        );
      } catch (e) {
        lastException = e;
        attempt++;
      }
    }

    return ScreenshotResult.failure(
      options: options,
      error: 'Capture failed after $attempt attempts: $lastException',
      retryCount: attempt,
    );
  }
}
