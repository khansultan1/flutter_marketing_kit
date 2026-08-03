/// Device type classification.
enum DeviceType {
  /// Smartphone form factor.
  phone,

  /// Tablet form factor.
  tablet,

  /// Foldable form factor.
  foldable,
}

/// Platform target classification.
enum TargetPlatformType {
  /// Android OS.
  android,

  /// iOS / iPadOS.
  ios,
}

/// Represents the hardware and screen specification of a device target.
class DeviceSpec {
  /// Creates a [DeviceSpec] instance.
  const DeviceSpec({
    required this.id,
    required this.name,
    required this.type,
    required this.platform,
    required this.width,
    required this.height,
    required this.pixelRatio,
    this.cornerScale = 0.08,
  });

  /// Unique canonical identifier string (e.g. 'pixel9', 'iphone16').
  final String id;

  /// Human-readable device display name.
  final String name;

  /// Device hardware category.
  final DeviceType type;

  /// Platform OS target.
  final TargetPlatformType platform;

  /// Logical or pixel width in points/pixels.
  final double width;

  /// Logical or pixel height in points/pixels.
  final double height;

  /// Display pixel ratio multiplier.
  final double pixelRatio;

  /// Corner radius scale for framing visuals.
  final double cornerScale;

  /// Preset device specifications supported out of the box.
  static const List<DeviceSpec> presets = [
    DeviceSpec(
      id: 'pixel9',
      name: 'Google Pixel 9',
      type: DeviceType.phone,
      platform: TargetPlatformType.android,
      width: 1080,
      height: 2424,
      pixelRatio: 3,
    ),
    DeviceSpec(
      id: 'pixelFold',
      name: 'Google Pixel Fold',
      type: DeviceType.foldable,
      platform: TargetPlatformType.android,
      width: 1840,
      height: 2208,
      pixelRatio: 3,
    ),
    DeviceSpec(
      id: 'galaxyS25',
      name: 'Samsung Galaxy S25',
      type: DeviceType.phone,
      platform: TargetPlatformType.android,
      width: 1080,
      height: 2340,
      pixelRatio: 3,
    ),
    DeviceSpec(
      id: 'galaxyTab',
      name: 'Samsung Galaxy Tab S9',
      type: DeviceType.tablet,
      platform: TargetPlatformType.android,
      width: 1600,
      height: 2560,
      pixelRatio: 2.5,
    ),
    DeviceSpec(
      id: 'iphone16',
      name: 'iPhone 16',
      type: DeviceType.phone,
      platform: TargetPlatformType.ios,
      width: 1179,
      height: 2556,
      pixelRatio: 3,
    ),
    DeviceSpec(
      id: 'iphone16Pro',
      name: 'iPhone 16 Pro',
      type: DeviceType.phone,
      platform: TargetPlatformType.ios,
      width: 1206,
      height: 2622,
      pixelRatio: 3,
    ),
    DeviceSpec(
      id: 'iphoneSE',
      name: 'iPhone SE (3rd Gen)',
      type: DeviceType.phone,
      platform: TargetPlatformType.ios,
      width: 750,
      height: 1334,
      pixelRatio: 2,
    ),
    DeviceSpec(
      id: 'ipad',
      name: 'iPad (10th Gen)',
      type: DeviceType.tablet,
      platform: TargetPlatformType.ios,
      width: 1640,
      height: 2360,
      pixelRatio: 2,
    ),
    DeviceSpec(
      id: 'ipadAir',
      name: 'iPad Air 11-inch',
      type: DeviceType.tablet,
      platform: TargetPlatformType.ios,
      width: 1640,
      height: 2360,
      pixelRatio: 2,
    ),
    DeviceSpec(
      id: 'ipadPro',
      name: 'iPad Pro 13-inch',
      type: DeviceType.tablet,
      platform: TargetPlatformType.ios,
      width: 2064,
      height: 2752,
      pixelRatio: 2,
    ),
  ];

  /// Find a preset device spec by ID. Returns null if not found.
  static DeviceSpec? findById(String id) {
    final search = id.toLowerCase();
    for (final spec in presets) {
      if (spec.id.toLowerCase() == search) {
        return spec;
      }
    }
    return null;
  }
}
