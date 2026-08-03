import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:config_engine/config_engine.dart';
import 'package:path/path.dart' as p;

/// CLI Command to initialize `playstore_assets.yaml` configuration.
class InitCommand extends Command<int> {
  /// Creates an instance of [InitCommand].
  InitCommand() {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite existing playstore_assets.yaml file if present.',
      )
      ..addOption(
        'output',
        abbr: 'o',
        defaultsTo: 'playstore_assets.yaml',
        help: 'Path where configuration YAML should be written.',
      );
  }

  @override
  String get name => 'init';

  @override
  String get description =>
      'Initialize configuration with comprehensive documentation.';

  @override
  Future<int> run() async {
    final outputPath =
        argResults?['output'] as String? ?? 'playstore_assets.yaml';
    final force = argResults?['force'] as bool? ?? false;

    final targetFile = File(p.canonicalize(outputPath));

    if (targetFile.existsSync() && !force) {
      stdout.writeln(
        '⚠️  Configuration file already exists at ${targetFile.path}\n'
        '   Use --force (-f) to overwrite.',
      );
      return 1;
    }

    final templateContent = YamlConfigParser.generateDefaultConfigYaml();
    await targetFile.writeAsString(templateContent);

    stdout.writeln(
      '✨ Successfully created configuration file: ${targetFile.path}\n'
      '   Edit this file to customize your app screens, colors, and assets.\n'
      '   Run `dart run flutter_marketing_kit generate` when ready!',
    );

    return 0;
  }
}
