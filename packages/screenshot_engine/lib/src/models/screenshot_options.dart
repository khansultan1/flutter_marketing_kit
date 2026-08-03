import 'package:shared/shared.dart';

/// Screen orientation during capture.
enum ScreenshotOrientation {
  /// Portrait layout (vertical).
  portrait,

  /// Landscape layout (horizontal).
  landscape,
}

/// Visual theme mode during capture.
enum ScreenshotThemeMode {
  /// Light background mode.
  light,

  /// Dark background mode.
  dark,
}

/// Configuration parameters for capturing an individual app screenshot.
class ScreenshotOptions {
  /// Creates a [ScreenshotOptions] instance.
  const ScreenshotOptions({
    required this.screenSpec,
    required this.deviceSpec,
    required this.outputFilePath,
    this.orientation = ScreenshotOrientation.portrait,
    this.themeMode = ScreenshotThemeMode.light,
    this.locale = 'en',
    this.highDpi = true,
    this.maxRetries = 3,
    this.animationWaitDuration = const Duration(milliseconds: 500),
  });

  /// Target screen route specification.
  final ScreenSpec screenSpec;

  /// Target hardware device specification.
  final DeviceSpec deviceSpec;

  /// Output destination file path.
  final String outputFilePath;

  /// Screen orientation (portrait/landscape).
  final ScreenshotOrientation orientation;

  /// Visual theme mode (light/dark).
  final ScreenshotThemeMode themeMode;

  /// Localization language code (e.g. `en`, `ar`).
  final String locale;

  /// Whether to render high-DPI retina screenshots using device pixel ratio.
  final bool highDpi;

  /// Maximum retry attempts on capture timeout or failure.
  final int maxRetries;

  /// Settle duration to wait for route transition animations to finish.
  final Duration animationWaitDuration;

  /// Calculate target capture width considering orientation & pixel ratio.
  int get captureWidth {
    final baseWidth = orientation == ScreenshotOrientation.portrait
        ? deviceSpec.width
        : deviceSpec.height;
    return (highDpi ? baseWidth * deviceSpec.pixelRatio : baseWidth).round();
  }

  /// Calculate target capture height considering orientation & pixel ratio.
  int get captureHeight {
    final baseHeight = orientation == ScreenshotOrientation.portrait
        ? deviceSpec.height
        : deviceSpec.width;
    return (highDpi ? baseHeight * deviceSpec.pixelRatio : baseHeight).round();
  }
}
