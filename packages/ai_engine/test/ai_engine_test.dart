import 'package:ai_engine/ai_engine.dart';
import 'package:test/test.dart';

void main() {
  group('AiEngine tests', () {
    const engine = AiEngine();

    test('registers all 6 requested AI providers', () {
      final providers = engine.availableProviders;
      expect(
        providers,
        containsAll([
          'gemini',
          'openai',
          'anthropic',
          'openrouter',
          'ollama',
          'lmstudio',
        ]),
      );
    });

    test('generates offline fallback copy when no API key provided', () async {
      final copy = await engine.generateCopy(appName: 'Expense AI');

      expect(copy.shortDescription, contains('Expense AI'));
      expect(copy.fullDescription, isNotEmpty);
      expect(copy.keywords, contains('expense ai'));
      expect(copy.privacyPolicy, contains('100% offline'));
    });

    test('uses AI provider when API key is provided', () async {
      final copy = await engine.generateCopy(
        appName: 'Expense AI',
        apiKey: 'test_key_123',
      );

      expect(copy.fullDescription, contains('[Gemini AI Generated Copy]'));
    });
  });
}
