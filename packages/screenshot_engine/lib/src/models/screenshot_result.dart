import 'package:screenshot_engine/src/models/screenshot_options.dart';

/// Result status payload from executing a screenshot capture operation.
class ScreenshotResult {
  /// Creates a successful [ScreenshotResult].
  const ScreenshotResult.success({
    required this.options,
    required this.filePath,
    required this.captureDuration,
    this.retryCount = 0,
  })  : isSuccess = true,
        error = null;

  /// Creates a failed [ScreenshotResult].
  const ScreenshotResult.failure({
    required this.options,
    required this.error,
    required this.retryCount,
    this.filePath,
  })  : isSuccess = false,
        captureDuration = Duration.zero;

  /// Original configuration options used for capture.
  final ScreenshotOptions options;

  /// Destination file path on disk (if successful).
  final String? filePath;

  /// Whether screenshot capture completed cleanly.
  final bool isSuccess;

  /// Error details string if capture failed.
  final String? error;

  /// Number of retries executed before returning result.
  final int retryCount;

  /// Execution time spent capturing screenshot.
  final Duration captureDuration;
}
