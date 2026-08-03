import 'package:image/image.dart' as img;
import 'package:image_engine/image_engine.dart';
import 'package:social_engine/src/models/social_platform_spec.dart';

/// Social graphic asset generator.
class SocialAssetGenerator {
  /// Creates a [SocialAssetGenerator] instance.
  const SocialAssetGenerator({
    ImageProcessor processor = const ImageProcessor(),
  }) : _processor = processor;

  final ImageProcessor _processor;

  /// Formats input image to match target social network [dimension].
  img.Image formatSocialAsset(
    img.Image input,
    SocialTargetDimension dimension,
  ) {
    return _processor.resize(
      input,
      width: dimension.width,
      height: dimension.height,
    );
  }
}
