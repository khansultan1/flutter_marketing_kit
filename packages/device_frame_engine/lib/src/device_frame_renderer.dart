import 'package:device_frame_engine/src/models/frame_style.dart';
import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:shared/shared.dart';

/// Renderer for framing screenshot bitmaps inside hardware device mockups.
class DeviceFrameRenderer {
  /// Creates a [DeviceFrameRenderer] with an optional image processor.
  const DeviceFrameRenderer({
    ImageProcessor processor = const ImageProcessor(),
  }) : _processor = processor;

  final ImageProcessor _processor;

  /// Render screenshot image into target [deviceSpec] hardware frame.
  img.Image frameScreenshot({
    required img.Image screenshot,
    required DeviceSpec deviceSpec,
    FrameStyle style = const FrameStyle(),
    int bezelPadding = 40,
  }) {
    // 1. Process screenshot rounded corners
    final roundedScreenshot = _processor.applyRoundedCorners(
      screenshot,
      radius: style.cornerRadius,
    );

    // 2. Compute framed container size
    final framedWidth = screenshot.width + (bezelPadding * 2);
    final framedHeight = screenshot.height + (bezelPadding * 2);

    // 3. Create canvas background for hardware bezel
    final canvas = img.Image(
      width: framedWidth,
      height: framedHeight,
      numChannels: 4,
    );

    // Draw outer bezel body
    final outerBezel = _processor.applyRoundedCorners(
      _processor.createGradientBackground(
        width: framedWidth,
        height: framedHeight,
        startHex: deviceSpec.platform == TargetPlatformType.ios
            ? '#2C2C2E'
            : '#1C1C1E',
        endHex: '#000000',
      ),
      radius: (style.cornerRadius + bezelPadding / 2).round(),
    );

    // Composite bezel and screenshot
    final withBezel = _processor.overlay(canvas, outerBezel);
    final framed = _processor.overlay(
      withBezel,
      roundedScreenshot,
      dstX: bezelPadding,
      dstY: bezelPadding,
    );

    // 4. Optionally add drop shadow
    if (style.hasShadow) {
      final shadowCanvas = img.Image(
        width: framedWidth + (style.shadowBlur * 2),
        height: framedHeight + (style.shadowBlur * 2),
        numChannels: 4,
      );

      final shadowShape = _processor.applyRoundedCorners(
        img.Image(
          width: framedWidth,
          height: framedHeight,
          numChannels: 4,
        ),
        radius: style.cornerRadius,
      );
      img.fill(shadowShape, color: img.ColorUint8.rgba(0, 0, 0, 100));

      final blurredShadow = _processor.gaussianBlur(
        shadowShape,
        radius: style.shadowBlur,
      );

      final resultWithShadow = _processor.overlay(
        shadowCanvas,
        blurredShadow,
        dstX: style.shadowBlur + style.shadowOffsetX,
        dstY: style.shadowBlur + style.shadowOffsetY,
      );

      return _processor.overlay(
        resultWithShadow,
        framed,
        dstX: style.shadowBlur,
        dstY: style.shadowBlur,
      );
    }

    return framed;
  }
}
