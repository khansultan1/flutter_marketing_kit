import 'package:flutter_marketing_kit/flutter_marketing_kit.dart';
import 'package:test/test.dart';

void main() {
  group('flutter_marketing_kit facade tests', () {
    test('exports shared models and CLI runner', () {
      expect(DeviceSpec.presets, isNotEmpty);
      final runner = MarketingCliCommandRunner();
      expect(runner.commands, isNotEmpty);
    });
  });
}
