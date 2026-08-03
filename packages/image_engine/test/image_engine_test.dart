import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:test/test.dart';

void main() {
  group('ImageProcessor tests', () {
    const processor = ImageProcessor();

    test('resizes image to target dimensions', () {
      final input = img.Image(width: 100, height: 100);
      final resized = processor.resize(input, width: 50, height: 50);

      expect(resized.width, equals(50));
      expect(resized.height, equals(50));
    });

    test('crops image region correctly', () {
      final input = img.Image(width: 200, height: 200);
      final cropped = processor.crop(
        input,
        x: 10,
        y: 10,
        width: 100,
        height: 100,
      );

      expect(cropped.width, equals(100));
      expect(cropped.height, equals(100));
    });

    test('applies rounded corners to image', () {
      final input = img.Image(width: 100, height: 100, numChannels: 4);
      img.fill(input, color: img.ColorUint8.rgba(255, 0, 0, 255));

      final rounded = processor.applyRoundedCorners(input, radius: 20);
      expect(rounded.width, equals(100));
      expect(rounded.height, equals(100));

      final pixel = rounded.getPixel(0, 0);
      expect(pixel.a.toInt(), equals(0));
    });

    test('creates gradient background', () {
      final bg = processor.createGradientBackground(
        width: 100,
        height: 100,
        startHex: '#FF0000',
        endHex: '#0000FF',
      );

      expect(bg.width, equals(100));
      expect(bg.height, equals(100));
    });

    test('encodes image to PNG byte array', () {
      final input = img.Image(width: 20, height: 20);
      final bytes = processor.encode(input);

      expect(bytes, isNotEmpty);
    });
  });
}
