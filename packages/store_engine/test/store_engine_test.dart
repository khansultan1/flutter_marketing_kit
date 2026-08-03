import 'package:image/image.dart' as img;
import 'package:shared/shared.dart';
import 'package:store_engine/store_engine.dart';
import 'package:test/test.dart';

void main() {
  group('StoreAssetGenerator tests', () {
    const generator = StoreAssetGenerator();

    test('defines required store dimensions across 5 platforms', () {
      expect(StoreAssetGenerator.storeDimensions.length, equals(5));
      expect(
        StoreAssetGenerator.storeDimensions.containsKey(
          StorePlatform.googlePlay,
        ),
        isTrue,
      );
      expect(
        StoreAssetGenerator.storeDimensions.containsKey(
          StorePlatform.appleAppStore,
        ),
        isTrue,
      );
    });

    test('formats image asset to match store target dimensions', () {
      final input = img.Image(width: 500, height: 500);
      final playDimensions = StoreAssetGenerator
          .storeDimensions[StorePlatform.googlePlay]!
          .firstWhere((d) => d.name == 'Feature Graphic');

      final formatted = generator.formatStoreAsset(input, playDimensions);
      expect(formatted.width, equals(1024));
      expect(formatted.height, equals(500));
    });
  });
}
