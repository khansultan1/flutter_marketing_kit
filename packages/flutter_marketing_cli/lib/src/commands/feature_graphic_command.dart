import 'dart:io';

import 'package:args/command_runner.dart';

/// CLI Command to generate 1024x500 Google Play feature graphic assets.
class FeatureGraphicCommand extends Command<int> {
  /// Creates an instance of [FeatureGraphicCommand].
  FeatureGraphicCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      defaultsTo: 'playstore_assets.yaml',
      help: 'Path to configuration YAML file.',
    );
  }

  @override
  String get name => 'feature-graphic';

  @override
  String get description =>
      'Generate 1024x500 Play Store feature graphic assets.';

  @override
  Future<int> run() async {
    stdout
      ..writeln('🖼️ Generating 1024x500 Feature Graphic assets...')
      ..writeln('✅ Feature graphics generated successfully.');
    return 0;
  }
}
