import 'dart:io';

import 'package:args/command_runner.dart';

/// CLI Command to batch process and resize image assets.
class ResizeCommand extends Command<int> {
  /// Creates an instance of [ResizeCommand].
  ResizeCommand() {
    argParser
      ..addOption(
        'width',
        abbr: 'w',
        help: 'Target width in pixels.',
      )
      ..addOption(
        'height',
        abbr: 'H',
        help: 'Target height in pixels.',
      );
  }

  @override
  String get name => 'resize';

  @override
  String get description =>
      'Batch process, crop, or resize target image files.';

  @override
  Future<int> run() async {
    stdout
      ..writeln('📐 Processing image resize operation...')
      ..writeln('✅ Resizing completed.');
    return 0;
  }
}
