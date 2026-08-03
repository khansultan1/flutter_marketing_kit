import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';

void main() {
  group('TemplateStyle tests', () {
    test('finds template style by name string', () {
      final style = TemplateStyle.findByName('gaming');
      expect(style.theme, equals(TemplateTheme.gaming));
      expect(style.isDark, isTrue);

      final fallback = TemplateStyle.findByName('non_existent');
      expect(fallback.theme, equals(TemplateTheme.modern));
    });

    test('contains all 11 required preset design themes', () {
      expect(TemplateStyle.presets.length, equals(11));
      expect(TemplateStyle.presets.containsKey(TemplateTheme.modern), isTrue);
      expect(TemplateStyle.presets.containsKey(TemplateTheme.minimal), isTrue);
      expect(
        TemplateStyle.presets.containsKey(TemplateTheme.material),
        isTrue,
      );
      expect(TemplateStyle.presets.containsKey(TemplateTheme.gaming), isTrue);
      expect(TemplateStyle.presets.containsKey(TemplateTheme.kids), isTrue);
      expect(TemplateStyle.presets.containsKey(TemplateTheme.finance), isTrue);
      expect(TemplateStyle.presets.containsKey(TemplateTheme.health), isTrue);
      expect(
        TemplateStyle.presets.containsKey(TemplateTheme.education),
        isTrue,
      );
      expect(
        TemplateStyle.presets.containsKey(TemplateTheme.gradient),
        isTrue,
      );
      expect(TemplateStyle.presets.containsKey(TemplateTheme.glass), isTrue);
      expect(TemplateStyle.presets.containsKey(TemplateTheme.dark), isTrue);
    });
  });
}
