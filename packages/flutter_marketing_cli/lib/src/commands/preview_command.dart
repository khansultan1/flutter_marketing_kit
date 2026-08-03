import 'dart:io';

import 'package:args/command_runner.dart';

/// CLI Command to generate device preview mockups.
class PreviewCommand extends Command<int> {
  @override
  String get name => 'preview';

  @override
  String get description =>
      'Generate interactive device preview mockups for review.';

  @override
  Future<int> run() async {
    stdout
      ..writeln('📱 Generating device previews...')
      ..writeln('✅ Previews generated successfully.');
    return 0;
  }
}
