/// Base exception class for all errors produced by flutter_marketing_kit.
class MarketingKitException implements Exception {
  /// Creates a [MarketingKitException] with a required message and details.
  const MarketingKitException(
    this.message, {
    this.details,
    this.suggestion,
  });

  /// Human-readable explanation of the error.
  final String message;

  /// Additional diagnostic details or stack information.
  final String? details;

  /// Recovery recommendation or action item for the developer.
  final String? suggestion;

  @override
  String toString() {
    final buffer = StringBuffer('MarketingKitException: $message');
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    if (suggestion != null) {
      buffer.write('\nSuggestion: $suggestion');
    }
    return buffer.toString();
  }
}

/// Exception thrown when configuration parsing or validation fails.
class ConfigurationException extends MarketingKitException {
  /// Creates a [ConfigurationException].
  const ConfigurationException(
    super.message, {
    super.details,
    super.suggestion,
  });
}

/// Exception thrown during CLI processing or arguments validation.
class CliException extends MarketingKitException {
  /// Creates a [CliException].
  const CliException(
    super.message, {
    super.details,
    super.suggestion,
  });
}
