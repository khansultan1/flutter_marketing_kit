/// Supported social network platforms.
enum SocialPlatform {
  /// LinkedIn professional network.
  linkedIn,

  /// Twitter / X social network.
  twitter,

  /// Facebook social network.
  facebook,

  /// Instagram social network.
  instagram,

  /// Threads social network.
  threads,

  /// Product Hunt product discovery.
  productHunt,

  /// GitHub open source repository.
  gitHub,
}

/// Target social graphic dimension specification.
class SocialTargetDimension {
  /// Creates a [SocialTargetDimension] instance.
  const SocialTargetDimension({
    required this.platform,
    required this.name,
    required this.width,
    required this.height,
  });

  /// Target social network platform.
  final SocialPlatform platform;

  /// Display name label.
  final String name;

  /// Target pixel width.
  final int width;

  /// Target pixel height.
  final int height;

  /// Preset dimensions across all social networks.
  static const List<SocialTargetDimension> presets = [
    SocialTargetDimension(
      platform: SocialPlatform.linkedIn,
      name: 'LinkedIn Post',
      width: 1200,
      height: 627,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.twitter,
      name: 'Twitter Card',
      width: 1200,
      height: 675,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.facebook,
      name: 'Facebook Share',
      width: 1200,
      height: 630,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.instagram,
      name: 'Instagram Square',
      width: 1080,
      height: 1080,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.instagram,
      name: 'Instagram Story',
      width: 1080,
      height: 1920,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.threads,
      name: 'Threads Post',
      width: 1080,
      height: 1920,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.productHunt,
      name: 'Product Hunt Banner',
      width: 1270,
      height: 760,
    ),
    SocialTargetDimension(
      platform: SocialPlatform.gitHub,
      name: 'GitHub Open Graph',
      width: 1200,
      height: 600,
    ),
  ];
}
