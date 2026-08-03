import 'package:device_frame_engine/device_frame_engine.dart';
import 'package:image/image.dart' as img;
import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('SvgFrameDefinitions tests', () {
    test('generates valid SVG string for device spec', () {
      final pixel = DeviceSpec.findById('pixel9')!;
      final svg = SvgFrameDefinitions.getSvgFrame(pixel);

      expect(svg, contains('<svg'));
      expect(svg, contains('width="1080"'));
      expect(svg, contains('height="2424"'));
    });
  });

  group('DeviceFrameRenderer tests', () {
    const renderer = DeviceFrameRenderer();

    test('frames screenshot bitmap with device bezel and shadow', () {
      final screenshot = img.Image(width: 200, height: 400, numChannels: 4);
      img.fill(screenshot, color: img.ColorUint8.rgba(0, 100, 250, 255));

      final pixel = DeviceSpec.findById('pixel9')!;
      final framed = renderer.frameScreenshot(
        screenshot: screenshot,
        deviceSpec: pixel,
      );

      expect(framed.width, greaterThan(200));
      expect(framed.height, greaterThan(400));
    });
  });
}
