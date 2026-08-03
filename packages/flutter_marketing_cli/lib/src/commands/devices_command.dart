import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:shared/shared.dart';

/// CLI Command to list all supported device frame specs.
class DevicesCommand extends Command<int> {
  @override
  String get name => 'devices';

  @override
  String get description =>
      'List supported hardware device specifications and viewports.';

  @override
  Future<int> run() async {
    stdout.writeln('📱 Supported Hardware Device Presets:\n');
    for (final spec in DeviceSpec.presets) {
      final idStr = spec.id.padRight(14);
      final nameStr = spec.name.padRight(22);
      final dimStr = '${spec.width.toInt()}x${spec.height.toInt()}';
      final ratioStr = '@${spec.pixelRatio}x';
      final platformStr = spec.platform.name.toUpperCase();
      stdout.writeln(
        '  • $idStr : $nameStr ($dimStr $ratioStr) [$platformStr]',
      );
    }
    return 0;
  }
}
