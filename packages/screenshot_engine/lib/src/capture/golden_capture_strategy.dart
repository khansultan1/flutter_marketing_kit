import 'package:screenshot_engine/src/capture/driver_capture_strategy.dart';

/// Golden test capture strategy adapter.
class GoldenCaptureStrategy extends DriverCaptureStrategy {
  /// Creates a [GoldenCaptureStrategy].
  const GoldenCaptureStrategy();

  @override
  String get name => 'GoldenTestCaptureStrategy';
}
