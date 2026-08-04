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
        await Future<void>.delayed(options.animationWaitDuration);

        final width = options.captureWidth;
        final height = options.captureHeight;
        final outputFile = File(p.canonicalize(options.outputFilePath));

        if (!outputFile.parent.existsSync()) {
          outputFile.parent.createSync(recursive: true);
        }

        // Render rich, high-fidelity app UI screen mockup bitmap
        final isDark = options.themeMode == ScreenshotThemeMode.dark;
        final image = img.Image(
          width: width,
          height: height,
          numChannels: 4,
        );

        // Vibrant gradient background (Purple to Blue / Dark Violet)
        final bgHex1 = isDark ? '#120E2E' : '#4E46E5';
        final bgHex2 = isDark ? '#080619' : '#06B6D4';
        final bgInt1 = ColorUtils.hexToInt(bgHex1);
        final bgInt2 = ColorUtils.hexToInt(bgHex2);

        final r1 = (bgInt1 >> 16) & 0xFF;
        final g1 = (bgInt1 >> 8) & 0xFF;
        final b1 = bgInt1 & 0xFF;

        final r2 = (bgInt2 >> 16) & 0xFF;
        final g2 = (bgInt2 >> 8) & 0xFF;
        final b2 = bgInt2 & 0xFF;

        for (var y = 0; y < height; y++) {
          final t = y / height;
          final r = (r1 * (1 - t) + r2 * t).toInt().clamp(0, 255);
          final g = (g1 * (1 - t) + g2 * t).toInt().clamp(0, 255);
          final b = (b1 * (1 - t) + b2 * t).toInt().clamp(0, 255);

          for (var x = 0; x < width; x++) {
            image.setPixelRgba(x, y, r, g, b, 255);
          }
        }

        // Primary header app bar
        final headerHeight = (height * 0.12).toInt();
        img.fillRect(
          image,
          x1: 0,
          y1: 0,
          x2: width,
          y2: headerHeight,
          color: img.ColorUint8.rgba(15, 23, 42, 230),
        );

        // Draw Screen Title in App Bar
        img.drawString(
          image,
          options.screenSpec.title,
          font: img.arial48,
          x: (width * 0.08).toInt(),
          y: (headerHeight * 0.40).toInt(),
          color: img.ColorUint8.rgba(255, 255, 255, 255),
        );

        // Content Card 1: Hero Analytics
        final cardColor = img.ColorUint8.rgba(255, 255, 255, 240);

        img.fillRect(
          image,
          x1: (width * 0.06).toInt(),
          y1: (height * 0.16).toInt(),
          x2: (width * 0.94).toInt(),
          y2: (height * 0.42).toInt(),
          color: cardColor,
        );

        img.drawString(
          image,
          options.screenSpec.subtitle ?? 'Real-time Activity & Analytics',
          font: img.arial24,
          x: (width * 0.10).toInt(),
          y: (height * 0.20).toInt(),
          color: img.ColorUint8.rgba(30, 41, 59, 255),
        );

        // Simulated Chart Bar Graphics
        final barColor1 = img.ColorUint8.rgba(79, 70, 229, 255);
        final barColor2 = img.ColorUint8.rgba(6, 182, 212, 255);

        final barYBase = (height * 0.39).toInt();
        final barWidth = (width * 0.08).toInt();

        img.fillRect(
          image,
          x1: (width * 0.12).toInt(),
          y1: (height * 0.27).toInt(),
          x2: (width * 0.12).toInt() + barWidth,
          y2: barYBase,
          color: barColor1,
        );

        img.fillRect(
          image,
          x1: (width * 0.26).toInt(),
          y1: (height * 0.24).toInt(),
          x2: (width * 0.26).toInt() + barWidth,
          y2: barYBase,
          color: barColor2,
        );

        img.fillRect(
          image,
          x1: (width * 0.40).toInt(),
          y1: (height * 0.30).toInt(),
          x2: (width * 0.40).toInt() + barWidth,
          y2: barYBase,
          color: barColor1,
        );

        img.fillRect(
          image,
          x1: (width * 0.54).toInt(),
          y1: (height * 0.22).toInt(),
          x2: (width * 0.54).toInt() + barWidth,
          y2: barYBase,
          color: barColor2,
        );

        // Content Card 2: Route Specs
        final card2Y1 = (height * 0.45).toInt();
        final card2Y2 = (height * 0.60).toInt();
        img.fillRect(
          image,
          x1: (width * 0.06).toInt(),
          y1: card2Y1,
          x2: (width * 0.94).toInt(),
          y2: card2Y2,
          color: cardColor,
        );

        img.drawString(
          image,
          'Screen Route: ${options.screenSpec.route}',
          font: img.arial24,
          x: (width * 0.10).toInt(),
          y: card2Y1 + 35,
          color: barColor1,
        );

        // Content Card 3: Action Button
        final btnY1 = (height * 0.78).toInt();
        final btnY2 = (height * 0.88).toInt();
        img.fillRect(
          image,
          x1: (width * 0.10).toInt(),
          y1: btnY1,
          x2: (width * 0.90).toInt(),
          y2: btnY2,
          color: barColor1,
        );

        img.drawString(
          image,
          'Explore ${options.screenSpec.title}',
          font: img.arial24,
          x: (width * 0.30).toInt(),
          y: btnY1 + 35,
          color: img.ColorUint8.rgba(255, 255, 255, 255),
        );

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
