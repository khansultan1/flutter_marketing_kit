import 'package:image/image.dart' as img;
import 'package:social_engine/social_engine.dart';
import 'package:test/test.dart';

void main() {
  group('SocialAssetGenerator tests', () {
    const generator = SocialAssetGenerator();

    test('contains social dimensions for 7 target platforms', () {
      expect(SocialTargetDimension.presets.length, equals(8));
    });

    test('formats image asset to match GitHub Open Graph resolution', () {
      final input = img.Image(width: 400, height: 400);
      final ghSpec = SocialTargetDimension.presets.firstWhere(
        (d) => d.platform == SocialPlatform.gitHub,
      );

      final formatted = generator.formatSocialAsset(input, ghSpec);
      expect(formatted.width, equals(1200));
      expect(formatted.height, equals(600));
    });
  });
}
