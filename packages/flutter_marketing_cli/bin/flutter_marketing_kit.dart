import 'dart:io';

import 'package:flutter_marketing_cli/src/command_runner.dart';

Future<void> main(List<String> args) async {
  final runner = MarketingCliCommandRunner();
  try {
    final exitCode = await runner.run(args) ?? 0;
    exit(exitCode);
  } catch (e) {
    stderr.writeln('Error running command: $e');
    exit(1);
  }
}
