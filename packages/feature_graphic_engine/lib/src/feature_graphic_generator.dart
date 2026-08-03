import 'package:device_frame_engine/device_frame_engine.dart';
import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:shared/shared.dart';
import 'package:template_engine/template_engine.dart';

/// Generator for creating 1024x500 Play Store feature graphics.
class FeatureGraphicGenerator {
  /// Creates a [FeatureGraphicGenerator] with optional dependencies.
  const FeatureGraphicGenerator({
    ImageProcessor processor = const ImageProcessor(),
    DeviceFrameRenderer frameRenderer = const DeviceFrameRenderer(),
  })  : _processor = processor,
        _frameRenderer = frameRenderer;

  final ImageProcessor _processor;
  final DeviceFrameRenderer _frameRenderer;

  /// Generate a 1024x500 Play Store feature graphic bitmap.
  img.Image generateFeatureGraphic({
    required String appName,
    required String subtitle,
    required TemplateStyle style,
    img.Image? deviceScreenshot,
    DeviceSpec? deviceSpec,
    img.Image? appIcon,
  }) {
    const width = 1024;
    const height = 500;

    // 1. Create gradient background
    final canvas = _processor.createGradientBackground(
      width: width,
      height: height,
      startHex: style.primaryColorHex,
      endHex: style.backgroundColorHex,
    );

    // 2. Draw text title and subtitle onto bitmap canvas
    img.drawString(
      canvas,
      appName,
      font: img.arial48,
      x: 60,
      y: 180,
      color: img.ColorUint8.rgba(255, 255, 255, 255),
    );

    img.drawString(
      canvas,
      subtitle,
      font: img.arial24,
      x: 60,
      y: 250,
      color: img.ColorUint8.rgba(220, 220, 240, 230),
    );

    // 3. Composite device mockup on right side if screenshot provided
    var result = canvas;
    if (deviceScreenshot != null && deviceSpec != null) {
      final scaledScreenshot = _processor.resize(
        deviceScreenshot,
        width: 320,
        height: 640,
      );

      final framedMockup = _frameRenderer.frameScreenshot(
        screenshot: scaledScreenshot,
        deviceSpec: deviceSpec,
        style: const FrameStyle(shadowBlur: 20),
        bezelPadding: 20,
      );

      result = _processor.overlay(
        result,
        framedMockup,
        dstX: 620,
        dstY: 40,
      );
    }

    // 4. Composite app icon on left if provided
    if (appIcon != null) {
      final resizedIcon = _processor.resize(appIcon, width: 80, height: 80);
      final roundedIcon = _processor.applyRoundedCorners(
        resizedIcon,
        radius: 16,
      );
      result = _processor.overlay(
        result,
        roundedIcon,
        dstX: 60,
        dstY: 70,
      );
    }

    return result;
  }
}
