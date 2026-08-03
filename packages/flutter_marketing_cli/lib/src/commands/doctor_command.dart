import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// CLI Command to run system and project diagnostics.
class DoctorCommand extends Command<int> {
  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Run diagnostic checks on workspace dependencies and tools.';

  @override
  Future<int> run() async {
    stdout.writeln('🩺 Running flutter_marketing_kit diagnostic checks...\n');

    final dartExec = Platform.executable;
    stdout.writeln('  [✓] Dart Executable : $dartExec');

    final configExist =
        File(p.canonicalize('playstore_assets.yaml')).existsSync();
    if (configExist) {
      stdout.writeln('  [✓] Configuration   : playstore_assets.yaml found');
    } else {
      stdout.writeln(
        '  [!] Configuration   : playstore_assets.yaml missing (Run `init`)',
      );
    }

    final pubspecExist = File(p.canonicalize('pubspec.yaml')).existsSync();
    if (pubspecExist) {
      stdout.writeln('  [✓] Flutter Project : Valid pubspec.yaml located');
    } else {
      stdout.writeln(
        '  [!] Flutter Project : pubspec.yaml not found in current dir',
      );
    }

    stdout.writeln('\n✨ Diagnostic checks completed.');
    return 0;
  }
}
