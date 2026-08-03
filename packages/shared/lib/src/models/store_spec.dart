/// Target digital app store distribution platforms.
enum StorePlatform {
  /// Google Play Store.
  googlePlay,

  /// Apple App Store.
  appleAppStore,

  /// Huawei AppGallery.
  huaweiAppGallery,

  /// Amazon Appstore.
  amazonAppstore,

  /// Microsoft Store.
  microsoftStore,
}

/// Specifications for store graphic assets.
class StoreSpec {
  /// Creates a [StoreSpec] instance.
  const StoreSpec({
    required this.platform,
    required this.displayName,
    required this.featureGraphicWidth,
    required this.featureGraphicHeight,
    required this.supportedOrientations,
  });

  /// Target platform identifier.
  final StorePlatform platform;

  /// Friendly display name.
  final String displayName;

  /// Required feature graphic width in pixels (or 0 if not required).
  final int featureGraphicWidth;

  /// Required feature graphic height in pixels (or 0 if not required).
  final int featureGraphicHeight;

  /// List of orientation options supported by store screenshots.
  final List<String> supportedOrientations;

  /// Standard Play Store feature graphic dimensions (1024x500).
  static const int defaultFeatureGraphicWidth = 1024;

  /// Standard Play Store feature graphic height (500).
  static const int defaultFeatureGraphicHeight = 500;
}
