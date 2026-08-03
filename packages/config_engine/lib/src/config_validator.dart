import 'package:shared/shared.dart';

/// Validator class for ensuring [MarketingConfig] object compliance.
class ConfigValidator {
  /// Creates a [ConfigValidator] instance.
  const ConfigValidator();

  /// Validates a [MarketingConfig] instance.
  /// Throws [ConfigurationException] if invalid.
  void validate(MarketingConfig config) {
    if (config.appName.trim().isEmpty) {
      throw const ConfigurationException(
        'App name cannot be empty.',
        suggestion: 'Provide a valid app_name in playstore_assets.yaml',
      );
    }

    if (config.packageName.trim().isEmpty) {
      throw const ConfigurationException(
        'Package name cannot be empty.',
        suggestion:
            'Provide a package_name (com.example.app) in playstore_assets.yaml',
      );
    }

    if (!ColorUtils.isValidHex(config.primaryColor)) {
      throw ConfigurationException(
        'Invalid primary_color HEX format: ${config.primaryColor}',
        suggestion: 'Use a standard HEX string like "#5E5CE6" or "#00C2FF"',
      );
    }

    if (!ColorUtils.isValidHex(config.accentColor)) {
      throw ConfigurationException(
        'Invalid accent_color HEX format: ${config.accentColor}',
        suggestion: 'Use a standard HEX string like "#5E5CE6" or "#00C2FF"',
      );
    }

    if (config.devices.isEmpty) {
      throw const ConfigurationException(
        'At least one target device must be specified.',
        suggestion: 'Add device IDs under "devices:" (e.g. pixel9, iphone16)',
      );
    }

    for (final deviceId in config.devices) {
      if (DeviceSpec.findById(deviceId) == null) {
        final presets = DeviceSpec.presets.map((d) => d.id).join(', ');
        throw ConfigurationException(
          'Unsupported device identifier: "$deviceId"',
          suggestion: 'Supported devices: $presets',
        );
      }
    }

    if (config.screens.isEmpty) {
      throw const ConfigurationException(
        'At least one screen route must be configured.',
        suggestion: 'Add screens under "screens:" mapping route and title.',
      );
    }
  }
}
