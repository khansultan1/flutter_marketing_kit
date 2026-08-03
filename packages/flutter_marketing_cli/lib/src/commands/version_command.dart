import 'dart:io';

import 'package:args/command_runner.dart';

/// CLI Command to print the current version.
class VersionCommand extends Command<int> {
  @override
  String get name => 'version';

  @override
  String get description => 'Display flutter_marketing_kit version details.';

  @override
  Future<int> run() async {
    stdout.writeln('flutter_marketing_kit version: 1.0.0');
    return 0;
  }
}
