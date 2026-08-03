import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:config_engine/config_engine.dart';
import 'package:path/path.dart' as p;
import 'package:screenshot_engine/screenshot_engine.dart';

/// CLI Command to capture raw application screenshots.
class ScreenshotsCommand extends Command<int> {
  /// Creates an instance of [ScreenshotsCommand].
  ScreenshotsCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      defaultsTo: 'playstore_assets.yaml',
      help: 'Path to configuration YAML file.',
    );
  }

  @override
  String get name => 'screenshots';

  @override
  String get description =>
      'Capture raw application screen captures via drivers.';

  @override
  Future<int> run() async {
    final configPath =
        argResults?['config'] as String? ?? 'playstore_assets.yaml';
    final configFile = File(p.canonicalize(configPath));

    if (!configFile.existsSync()) {
      stderr.writeln('❌ Config file not found: ${configFile.path}');
      return 1;
    }

    const parser = YamlConfigParser();
    final config = parser.parse(await configFile.readAsString());

    stdout.writeln('📸 Capturing application screen shots...');
    const engine = ScreenshotEngine();
    final results = await engine.captureBatch(config);

    final successCount = results.where((r) => r.isSuccess).length;
    stdout.writeln(
      '✅ Captured $successCount of ${results.length} screenshots.',
    );

    return 0;
  }
}
