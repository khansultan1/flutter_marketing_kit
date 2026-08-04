import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:screenshot_engine/src/capture/screenshot_capture_strategy.dart';
import 'package:screenshot_engine/src/models/screenshot_options.dart';
import 'package:screenshot_engine/src/models/screenshot_result.dart';

/// Driver capture strategy that renders a rich UI mockup using the image
/// package at native device resolution (no highDpi pixel multiplication).
class DriverCaptureStrategy implements ScreenshotCaptureStrategy {
  /// Creates a [DriverCaptureStrategy].
  const DriverCaptureStrategy();

  @override
  String get name => 'FlutterDriverCaptureStrategy';

  @override
  Future<ScreenshotResult> capture(ScreenshotOptions options) async {
    final stopwatch = Stopwatch()..start();

    // Always render at native device resolution to avoid OOM on high-DPI
    final width = options.deviceSpec.width.toInt();
    final height = options.deviceSpec.height.toInt();

    final outputFile = File(p.canonicalize(options.outputFilePath));
    if (!outputFile.parent.existsSync()) {
      outputFile.parent.createSync(recursive: true);
    }

    try {
      final isDark = options.themeMode == ScreenshotThemeMode.dark;

      // ── Image canvas ─────────────────────────────────────────────────────
      final image = img.Image(width: width, height: height, numChannels: 4);

      // ── Background ───────────────────────────────────────────────────────
      // Fast solid fill — indigo or near-black
      img.fill(
        image,
        color: isDark
            ? img.ColorUint8.rgba(12, 10, 30, 255)
            : img.ColorUint8.rgba(78, 70, 229, 255),
      );

      // Lower cyan band to simulate a vertical gradient cheaply
      img.fillRect(
        image,
        x1: 0,
        y1: (height * 0.40).toInt(),
        x2: width,
        y2: (height * 0.55).toInt(),
        color: img.ColorUint8.rgba(45, 120, 210, 255),
      );
      img.fillRect(
        image,
        x1: 0,
        y1: (height * 0.55).toInt(),
        x2: width,
        y2: height,
        color: img.ColorUint8.rgba(6, 182, 212, 255),
      );

      // ── App Bar ──────────────────────────────────────────────────────────
      final headerH = (height * 0.11).toInt();
      img.fillRect(
        image,
        x1: 0,
        y1: 0,
        x2: width,
        y2: headerH,
        color: img.ColorUint8.rgba(15, 10, 45, 210),
      );

      img.drawString(
        image,
        options.screenSpec.title,
        font: img.arial48,
        x: 48,
        y: (headerH * 0.38).toInt(),
        color: img.ColorUint8.rgba(255, 255, 255, 255),
      );

      // ── White content card ────────────────────────────────────────────────
      final cardX1 = (width * 0.06).toInt();
      final cardX2 = (width * 0.94).toInt();
      final cardY1 = (height * 0.15).toInt();
      final cardY2 = (height * 0.75).toInt();

      img.fillRect(
        image,
        x1: cardX1,
        y1: cardY1,
        x2: cardX2,
        y2: cardY2,
        color: img.ColorUint8.rgba(255, 255, 255, 245),
      );

      // Icon circle inside card
      img.fillCircle(
        image,
        x: width ~/ 2,
        y: cardY1 + (height * 0.10).toInt(),
        radius: (width * 0.10).toInt(),
        color: img.ColorUint8.rgba(78, 70, 229, 255),
      );

      // Screen title text inside card
      final titleY = cardY1 + (height * 0.22).toInt();
      img.drawString(
        image,
        options.screenSpec.title,
        font: img.arial48,
        x: cardX1 + 32,
        y: titleY,
        color: img.ColorUint8.rgba(15, 23, 42, 255),
      );

      // Subtitle text
      final subText =
          options.screenSpec.subtitle ?? options.screenSpec.route;
      img.drawString(
        image,
        subText,
        font: img.arial24,
        x: cardX1 + 32,
        y: titleY + 70,
        color: img.ColorUint8.rgba(100, 116, 139, 255),
      );

      // Divider
      img.drawLine(
        image,
        x1: cardX1 + 32,
        y1: titleY + 125,
        x2: cardX2 - 32,
        y2: titleY + 125,
        color: img.ColorUint8.rgba(226, 232, 240, 255),
        thickness: 2,
      );

      // Chart bars
      final barBaseY = cardY1 + (height * 0.56).toInt();
      final barW = (width * 0.10).toInt();
      final gap = (width * 0.04).toInt();
      final barStartX = cardX1 + 32;
      final purple = img.ColorUint8.rgba(78, 70, 229, 255);
      final cyan = img.ColorUint8.rgba(6, 182, 212, 255);

      img.fillRect(
        image,
        x1: barStartX,
        y1: barBaseY - (height * 0.10).toInt(),
        x2: barStartX + barW,
        y2: barBaseY,
        color: purple,
      );
      img.fillRect(
        image,
        x1: barStartX + barW + gap,
        y1: barBaseY - (height * 0.14).toInt(),
        x2: barStartX + barW * 2 + gap,
        y2: barBaseY,
        color: cyan,
      );
      img.fillRect(
        image,
        x1: barStartX + (barW + gap) * 2,
        y1: barBaseY - (height * 0.08).toInt(),
        x2: barStartX + barW * 3 + gap * 2,
        y2: barBaseY,
        color: purple,
      );
      img.fillRect(
        image,
        x1: barStartX + (barW + gap) * 3,
        y1: barBaseY - (height * 0.16).toInt(),
        x2: barStartX + barW * 4 + gap * 3,
        y2: barBaseY,
        color: cyan,
      );

      // ── CTA Button ────────────────────────────────────────────────────────
      final btnY1 = (height * 0.80).toInt();
      final btnY2 = (height * 0.90).toInt();
      img.fillRect(
        image,
        x1: (width * 0.10).toInt(),
        y1: btnY1,
        x2: (width * 0.90).toInt(),
        y2: btnY2,
        color: img.ColorUint8.rgba(78, 70, 229, 255),
      );
      img.drawString(
        image,
        'Get Started',
        font: img.arial24,
        x: (width * 0.38).toInt(),
        y: btnY1 + 30,
        color: img.ColorUint8.rgba(255, 255, 255, 255),
      );

      // ── Bottom nav bar ────────────────────────────────────────────────────
      img.fillRect(
        image,
        x1: 0,
        y1: (height * 0.91).toInt(),
        x2: width,
        y2: height,
        color: img.ColorUint8.rgba(15, 10, 45, 255),
      );

      final pngBytes = img.encodePng(image);
      await outputFile.writeAsBytes(pngBytes);

      stopwatch.stop();
      return ScreenshotResult.success(
        options: options,
        filePath: outputFile.path,
        captureDuration: stopwatch.elapsed,
      );
    } catch (e) {
      return ScreenshotResult.failure(
        options: options,
        error: 'Capture failed: $e',
        retryCount: 0,
      );
    }
  }
}
