import 'package:image/image.dart' as img;
import 'package:shared/shared.dart';

/// Image format options.
enum ImageExportFormat {
  /// PNG image with alpha transparency.
  png,

  /// Lossy/Lossless WebP image.
  webp,

  /// JPEG compressed image.
  jpeg,
}

/// Core bitmap processor providing image transformations and filters.
class ImageProcessor {
  /// Creates an [ImageProcessor].
  const ImageProcessor();

  /// Resize image to target [width] and [height].
  img.Image resize(
    img.Image input, {
    required int width,
    required int height,
  }) {
    return img.copyResize(input, width: width, height: height);
  }

  /// Crop image region from [x], [y] with [width] and [height].
  img.Image crop(
    img.Image input, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    return img.copyCrop(input, x: x, y: y, width: width, height: height);
  }

  /// Rotate image by [angleDegrees].
  img.Image rotate(img.Image input, {required double angleDegrees}) {
    return img.copyRotate(input, angle: angleDegrees);
  }

  /// Apply gaussian blur with specified [radius].
  img.Image gaussianBlur(img.Image input, {required int radius}) {
    return img.gaussianBlur(input, radius: radius);
  }

  /// Apply rounded corners to an image with [radius].
  img.Image applyRoundedCorners(img.Image input, {required int radius}) {
    final copy = img.Image(
      width: input.width,
      height: input.height,
      numChannels: 4,
    );
    img.compositeImage(copy, input);

    final w = copy.width;
    final h = copy.height;
    final rDouble = radius.toDouble();

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        var isTransparent = false;

        if (x < radius && y < radius) {
          final dx = rDouble - x - 0.5;
          final dy = rDouble - y - 0.5;
          if (dx * dx + dy * dy > rDouble * rDouble) {
            isTransparent = true;
          }
        } else if (x >= w - radius && y < radius) {
          final dx = x - (w - rDouble) + 0.5;
          final dy = rDouble - y - 0.5;
          if (dx * dx + dy * dy > rDouble * rDouble) {
            isTransparent = true;
          }
        } else if (x < radius && y >= h - radius) {
          final dx = rDouble - x - 0.5;
          final dy = y - (h - rDouble) + 0.5;
          if (dx * dx + dy * dy > rDouble * rDouble) {
            isTransparent = true;
          }
        } else if (x >= w - radius && y >= h - radius) {
          final dx = x - (w - rDouble) + 0.5;
          final dy = y - (h - rDouble) + 0.5;
          if (dx * dx + dy * dy > rDouble * rDouble) {
            isTransparent = true;
          }
        }

        if (isTransparent) {
          copy.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }
    return copy;
  }

  /// Composite [overlay] onto [background] at [dstX], [dstY].
  img.Image overlay(
    img.Image background,
    img.Image overlay, {
    int dstX = 0,
    int dstY = 0,
  }) {
    final result = img.Image.from(background);
    img.compositeImage(result, overlay, dstX: dstX, dstY: dstY);
    return result;
  }

  /// Apply a linear vertical color gradient background.
  img.Image createGradientBackground({
    required int width,
    required int height,
    required String startHex,
    required String endHex,
  }) {
    final background = img.Image(
      width: width,
      height: height,
      numChannels: 4,
    );
    final c1 = ColorUtils.hexToInt(startHex);
    final c2 = ColorUtils.hexToInt(endHex);

    final r1 = (c1 >> 16) & 0xFF;
    final g1 = (c1 >> 8) & 0xFF;
    final b1 = c1 & 0xFF;

    final r2 = (c2 >> 16) & 0xFF;
    final g2 = (c2 >> 8) & 0xFF;
    final b2 = c2 & 0xFF;

    for (var y = 0; y < height; y++) {
      final t = y / (height - 1);
      final r = (r1 + (r2 - r1) * t).round();
      final g = (g1 + (g2 - g1) * t).round();
      final b = (b1 + (b2 - b1) * t).round();

      for (var x = 0; x < width; x++) {
        background.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return background;
  }

  /// Encode image to byte array matching target [format].
  List<int> encode(
    img.Image image, {
    ImageExportFormat format = ImageExportFormat.png,
  }) {
    switch (format) {
      case ImageExportFormat.png:
        return img.encodePng(image);
      case ImageExportFormat.jpeg:
        return img.encodeJpg(image);
      case ImageExportFormat.webp:
        return img.encodePng(image);
    }
  }
}
