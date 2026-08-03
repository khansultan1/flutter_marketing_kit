/// Visual styling parameters for device mockup rendering.
class FrameStyle {
  /// Creates a [FrameStyle] instance.
  const FrameStyle({
    this.hasShadow = true,
    this.shadowBlur = 30,
    this.shadowOffsetX = 0,
    this.shadowOffsetY = 15,
    this.shadowOpacity = 0.4,
    this.cornerRadius = 40,
    this.perspectiveScale = 1.0,
  });

  /// Whether drop shadow filter is applied below the device bezel.
  final bool hasShadow;

  /// Blur radius of the drop shadow.
  final int shadowBlur;

  /// Horizontal offset of the drop shadow.
  final int shadowOffsetX;

  /// Vertical offset of the drop shadow.
  final int shadowOffsetY;

  /// Opacity multiplier for the drop shadow (0.0 to 1.0).
  final double shadowOpacity;

  /// Corner radius in pixels for screen rounding.
  final int cornerRadius;

  /// Perspective scale factor for dynamic mockup positioning.
  final double perspectiveScale;
}
