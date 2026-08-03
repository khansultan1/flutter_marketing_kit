import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:shared/shared.dart';

/// App store preset target dimension requirements.
class StoreTargetDimension {
  /// Creates a [StoreTargetDimension] instance.
  const StoreTargetDimension({
    required this.name,
    required this.width,
    required this.height,
  });

  /// Store target asset display label.
  final String name;

  /// Target width in pixels.
  final int width;

  /// Target height in pixels.
  final int height;
}

/// Asset generator producing store-compliant graphics across platforms.
class StoreAssetGenerator {
  /// Creates a [StoreAssetGenerator] instance.
  const StoreAssetGenerator({
    ImageProcessor processor = const ImageProcessor(),
  }) : _processor = processor;

  final ImageProcessor _processor;

  /// Store target platform resolutions.
  static const Map<StorePlatform, List<StoreTargetDimension>> storeDimensions =
      {
    StorePlatform.googlePlay: [
      StoreTargetDimension(
        name: 'Phone Screenshot',
        width: 1080,
        height: 1920,
      ),
      StoreTargetDimension(
        name: '7-inch Tablet',
        width: 1200,
        height: 1920,
      ),
      StoreTargetDimension(
        name: '10-inch Tablet',
        width: 1600,
        height: 2560,
      ),
      StoreTargetDimension(
        name: 'Feature Graphic',
        width: 1024,
        height: 500,
      ),
      StoreTargetDimension(
        name: 'App Icon',
        width: 512,
        height: 512,
      ),
    ],
    StorePlatform.appleAppStore: [
      StoreTargetDimension(
        name: '6.7-inch iPhone',
        width: 1290,
        height: 2796,
      ),
      StoreTargetDimension(
        name: '6.5-inch iPhone',
        width: 1242,
        height: 2688,
      ),
      StoreTargetDimension(
        name: '5.5-inch iPhone',
        width: 1242,
        height: 2208,
      ),
      StoreTargetDimension(
        name: '12.9-inch iPad Pro',
        width: 2048,
        height: 2732,
      ),
      StoreTargetDimension(
        name: 'App Icon',
        width: 1024,
        height: 1024,
      ),
    ],
    StorePlatform.huaweiAppGallery: [
      StoreTargetDimension(
        name: 'Phone Screenshot',
        width: 1080,
        height: 1920,
      ),
      StoreTargetDimension(
        name: 'App Icon',
        width: 216,
        height: 216,
      ),
    ],
    StorePlatform.amazonAppstore: [
      StoreTargetDimension(
        name: 'Phone Screenshot',
        width: 1080,
        height: 1920,
      ),
      StoreTargetDimension(
        name: 'App Icon',
        width: 512,
        height: 512,
      ),
    ],
    StorePlatform.microsoftStore: [
      StoreTargetDimension(
        name: 'Desktop Screenshot',
        width: 1920,
        height: 1080,
      ),
      StoreTargetDimension(
        name: 'Store Logo',
        width: 300,
        height: 300,
      ),
    ],
  };

  /// Resize input image asset to match store target specification.
  img.Image formatStoreAsset(
    img.Image input,
    StoreTargetDimension dimension,
  ) {
    return _processor.resize(
      input,
      width: dimension.width,
      height: dimension.height,
    );
  }
}
