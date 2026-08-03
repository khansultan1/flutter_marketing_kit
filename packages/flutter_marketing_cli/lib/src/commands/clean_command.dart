import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// CLI Command to clean generated marketing output files.
class CleanCommand extends Command<int> {
  /// Creates an instance of [CleanCommand].
  CleanCommand() {
    argParser.addOption(
      'dir',
      abbr: 'd',
      defaultsTo: 'marketing',
      help: 'Directory to clean.',
    );
  }

  @override
  String get name => 'clean';

  @override
  String get description =>
      'Clean generated marketing asset artifacts and output directory.';

  @override
  Future<int> run() async {
    final dirPath = argResults?['dir'] as String? ?? 'marketing';
    final targetDir = Directory(p.canonicalize(dirPath));

    if (targetDir.existsSync()) {
      targetDir.deleteSync(recursive: true);
      stdout.writeln('🧹 Cleaned directory: ${targetDir.path}');
    } else {
      stdout.writeln('🧹 Directory already clean: ${targetDir.path}');
    }
    return 0;
  }
}
