import 'package:shared/src/models/device_spec.dart';

/// Specification for a single application screen route to capture.
class ScreenSpec {
  /// Creates a [ScreenSpec] instance.
  const ScreenSpec({
    required this.id,
    required this.route,
    required this.title,
    this.subtitle,
  });

  /// Internal identifier key.
  final String id;

  /// Flutter application route (e.g., `/`, `/premium`).
  final String route;

  /// Screen headline or title text for marketing overlays.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;
}

/// Structured configuration settings loaded from `playstore_assets.yaml`.
class MarketingConfig {
  /// Creates a [MarketingConfig] instance.
  const MarketingConfig({
    required this.appName,
    required this.packageName,
    required this.outputDirectory,
    required this.theme,
    required this.template,
    required this.primaryColor,
    required this.accentColor,
    required this.devices,
    required this.languages,
    required this.screens,
    this.aiApiKey,
    this.aiProvider = 'gemini',
  });

  /// Name of the application.
  final String appName;

  /// Package or bundle identifier (e.g. `com.example.app`).
  final String packageName;

  /// Target output directory path relative to workspace.
  final String outputDirectory;

  /// Visual theme preset name (`modern`, `minimal`, etc.).
  final String theme;

  /// Visual template preset name.
  final String template;

  /// Primary HEX color string (`#5E5CE6`).
  final String primaryColor;

  /// Accent HEX color string (`#00C2FF`).
  final String accentColor;

  /// List of target device identifiers.
  final List<String> devices;

  /// List of target locale codes (`en`, `ar`, `es`, etc.).
  final List<String> languages;

  /// Map of screen configurations keyed by screen ID.
  final Map<String, ScreenSpec> screens;

  /// Optional API key for AI engine integrations.
  final String? aiApiKey;

  /// AI Provider key (`gemini`, `openai`, `anthropic`, etc.).
  final String aiProvider;

  /// Resolve configured device IDs into resolved [DeviceSpec] instances.
  List<DeviceSpec> get resolvedDevices {
    final list = <DeviceSpec>[];
    for (final id in devices) {
      final spec = DeviceSpec.findById(id);
      if (spec != null) {
        list.add(spec);
      }
    }
    return list;
  }
}
