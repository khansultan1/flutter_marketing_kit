import 'package:flutter_marketing_cli/flutter_marketing_cli.dart';
import 'package:test/test.dart';

void main() {
  group('MarketingCliCommandRunner tests', () {
    late MarketingCliCommandRunner runner;

    setUp(() {
      runner = MarketingCliCommandRunner();
    });

    test('registers all required CLI commands', () {
      final commands = runner.commands.keys.toList();
      expect(
        commands,
        containsAll([
          'init',
          'generate',
          'screenshots',
          'frames',
          'templates',
          'devices',
          'feature-graphic',
          'doctor',
          'preview',
          'resize',
          'clean',
          'version',
          'help',
        ]),
      );
    });
  });
}
