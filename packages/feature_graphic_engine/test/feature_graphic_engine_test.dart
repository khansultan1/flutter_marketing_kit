import 'package:feature_graphic_engine/feature_graphic_engine.dart';
import 'package:image/image.dart' as img;
import 'package:shared/shared.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';

void main() {
  group('FeatureGraphicGenerator tests', () {
    const generator = FeatureGraphicGenerator();

    test('generates 1024x500 feature graphic image', () {
      final style = TemplateStyle.findByName('gaming');
      final featureGraphic = generator.generateFeatureGraphic(
        appName: 'Expense AI',
        subtitle: 'Track your expenses smartly',
        style: style,
      );

      expect(featureGraphic.width, equals(1024));
      expect(featureGraphic.height, equals(500));
    });

    test('composites device screenshot and icon into feature graphic', () {
      final style = TemplateStyle.findByName('modern');
      final screenshot = img.Image(width: 300, height: 600, numChannels: 4);
      final icon = img.Image(width: 100, height: 100, numChannels: 4);
      final pixel = DeviceSpec.findById('pixel9')!;

      final featureGraphic = generator.generateFeatureGraphic(
        appName: 'Expense AI',
        subtitle: 'Track your expenses smartly',
        style: style,
        deviceScreenshot: screenshot,
        deviceSpec: pixel,
        appIcon: icon,
      );

      expect(featureGraphic.width, equals(1024));
      expect(featureGraphic.height, equals(500));
    });
  });
}
