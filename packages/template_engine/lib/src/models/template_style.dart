/// Supported design template themes.
enum TemplateTheme {
  /// Sleek modern glassmorphism design.
  modern,

  /// Clean minimal monochromatic design.
  minimal,

  /// Material 3 dynamic color scheme.
  material,

  /// High-contrast neon gaming theme.
  gaming,

  /// Playful geometry and pastel colors.
  kids,

  /// Corporate finance layout with gridlines.
  finance,

  /// Organic soothing health theme.
  health,

  /// Structured block education theme.
  education,

  /// Vibrant gradient theme.
  gradient,

  /// Frost glassmorphism theme.
  glass,

  /// Deep dark mode aesthetic.
  dark,
}

/// Visual design tokens and layout styling for templates.
class TemplateStyle {
  /// Creates a [TemplateStyle] instance.
  const TemplateStyle({
    required this.theme,
    required this.primaryColorHex,
    required this.accentColorHex,
    required this.backgroundColorHex,
    required this.textColorHex,
    required this.subtitleColorHex,
    this.fontFamily = 'Inter',
    this.isDark = false,
    this.hasGlassEffect = false,
  });

  /// Template theme designation.
  final TemplateTheme theme;

  /// Primary color string.
  final String primaryColorHex;

  /// Accent color string.
  final String accentColorHex;

  /// Background color string.
  final String backgroundColorHex;

  /// Main text title color string.
  final String textColorHex;

  /// Subtitle color string.
  final String subtitleColorHex;

  /// Typography font family name.
  final String fontFamily;

  /// Whether theme is dark mode.
  final bool isDark;

  /// Whether glassmorphism overlay is active.
  final bool hasGlassEffect;

  /// Preset template styles out of the box.
  static const Map<TemplateTheme, TemplateStyle> presets = {
    TemplateTheme.modern: TemplateStyle(
      theme: TemplateTheme.modern,
      primaryColorHex: '#5E5CE6',
      accentColorHex: '#00C2FF',
      backgroundColorHex: '#0F0F1A',
      textColorHex: '#FFFFFF',
      subtitleColorHex: '#A0A0B2',
      isDark: true,
      hasGlassEffect: true,
    ),
    TemplateTheme.minimal: TemplateStyle(
      theme: TemplateTheme.minimal,
      primaryColorHex: '#111111',
      accentColorHex: '#444444',
      backgroundColorHex: '#F8F9FA',
      textColorHex: '#111111',
      subtitleColorHex: '#666666',
    ),
    TemplateTheme.material: TemplateStyle(
      theme: TemplateTheme.material,
      primaryColorHex: '#6750A4',
      accentColorHex: '#7D5260',
      backgroundColorHex: '#FEF7FF',
      textColorHex: '#1D1B20',
      subtitleColorHex: '#49454F',
    ),
    TemplateTheme.gaming: TemplateStyle(
      theme: TemplateTheme.gaming,
      primaryColorHex: '#FF0055',
      accentColorHex: '#00FFCC',
      backgroundColorHex: '#0A0A0F',
      textColorHex: '#FFFFFF',
      subtitleColorHex: '#00FFCC',
      isDark: true,
    ),
    TemplateTheme.kids: TemplateStyle(
      theme: TemplateTheme.kids,
      primaryColorHex: '#FF9500',
      accentColorHex: '#FF2D55',
      backgroundColorHex: '#FFF8E7',
      textColorHex: '#2C1A04',
      subtitleColorHex: '#8E5A00',
    ),
    TemplateTheme.finance: TemplateStyle(
      theme: TemplateTheme.finance,
      primaryColorHex: '#0052CC',
      accentColorHex: '#00B8D9',
      backgroundColorHex: '#F4F5F7',
      textColorHex: '#172B4D',
      subtitleColorHex: '#5E6C84',
    ),
    TemplateTheme.health: TemplateStyle(
      theme: TemplateTheme.health,
      primaryColorHex: '#34C759',
      accentColorHex: '#30B0C7',
      backgroundColorHex: '#F2FAF4',
      textColorHex: '#0E3A19',
      subtitleColorHex: '#2C7A43',
    ),
    TemplateTheme.education: TemplateStyle(
      theme: TemplateTheme.education,
      primaryColorHex: '#5856D6',
      accentColorHex: '#FF9500',
      backgroundColorHex: '#F8F7FF',
      textColorHex: '#1C1B33',
      subtitleColorHex: '#4A4870',
    ),
    TemplateTheme.gradient: TemplateStyle(
      theme: TemplateTheme.gradient,
      primaryColorHex: '#FF5E3A',
      accentColorHex: '#FF2A68',
      backgroundColorHex: '#110927',
      textColorHex: '#FFFFFF',
      subtitleColorHex: '#FFD6CD',
      isDark: true,
    ),
    TemplateTheme.glass: TemplateStyle(
      theme: TemplateTheme.glass,
      primaryColorHex: '#00C6FF',
      accentColorHex: '#0072FF',
      backgroundColorHex: '#08121E',
      textColorHex: '#FFFFFF',
      subtitleColorHex: '#BBE1FF',
      isDark: true,
      hasGlassEffect: true,
    ),
    TemplateTheme.dark: TemplateStyle(
      theme: TemplateTheme.dark,
      primaryColorHex: '#0A84FF',
      accentColorHex: '#5E5CE6',
      backgroundColorHex: '#000000',
      textColorHex: '#FFFFFF',
      subtitleColorHex: '#8E8E93',
      isDark: true,
    ),
  };

  /// Find template style by name string. Defaults to `modern` if not found.
  static TemplateStyle findByName(String name) {
    final search = name.toLowerCase().trim();
    for (final entry in presets.entries) {
      if (entry.key.name.toLowerCase() == search) {
        return entry.value;
      }
    }
    return presets[TemplateTheme.modern]!;
  }
}
