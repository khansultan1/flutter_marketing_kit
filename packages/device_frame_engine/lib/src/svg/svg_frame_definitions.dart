import 'package:shared/shared.dart';

/// Vector SVG bezel definition manager.
class SvgFrameDefinitions {
  const SvgFrameDefinitions._();

  /// Retrieve raw SVG frame markup template for [deviceSpec].
  static String getSvgFrame(DeviceSpec deviceSpec) {
    final w = deviceSpec.width.toInt();
    final h = deviceSpec.height.toInt();
    final rx = (w * deviceSpec.cornerScale).round();

    return '''
<svg width="$w" height="$h" viewBox="0 0 $w $h" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="0" width="$w" height="$h" rx="$rx" fill="#1C1C1E" stroke="#3A3A3C" stroke-width="8"/>
</svg>
''';
  }
}
