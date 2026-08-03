import 'package:screenshot_engine/src/models/screenshot_options.dart';
import 'package:screenshot_engine/src/models/screenshot_result.dart';

/// Strategy interface for capturing app screenshots across different backends.
abstract class ScreenshotCaptureStrategy {
  /// Name of the capture strategy implementation.
  String get name;

  /// Executes screenshot capture according to [options].
  Future<ScreenshotResult> capture(ScreenshotOptions options);
}
