import 'package:config_engine/config_engine.dart';
import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('YamlConfigParser tests', () {
    const parser = YamlConfigParser();

    test('parses default config YAML successfully', () {
      final defaultYaml = YamlConfigParser.generateDefaultConfigYaml();
      final config = parser.parse(defaultYaml);

      expect(config.appName, equals('Expense AI'));
      expect(config.packageName, equals('com.example.expense'));
      expect(config.outputDirectory, equals('marketing'));
      expect(config.theme, equals('modern'));
      expect(config.primaryColor, equals('#5E5CE6'));
      expect(config.devices, containsAll(['pixel9', 'iphone16', 'ipad']));
      expect(config.languages, containsAll(['en', 'ar']));
      expect(config.screens.length, equals(3));
      expect(config.screens['home']?.route, equals('/'));
      expect(config.screens['home']?.title, equals('Smart Dashboard'));
    });

    test('throws ConfigurationException when app_name is empty', () {
      const invalidYaml = '''
app_name: ""
package_name: com.example.app
primary_color: "#5E5CE6"
accent_color: "#00C2FF"
devices:
  - pixel9
screens:
  home:
    route: /
    title: Home
''';
      expect(
        () => parser.parse(invalidYaml),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('throws ConfigurationException on invalid device ID', () {
      const invalidYaml = '''
app_name: "App"
package_name: com.example.app
primary_color: "#5E5CE6"
accent_color: "#00C2FF"
devices:
  - non_existent_device
screens:
  home:
    route: /
    title: Home
''';
      expect(
        () => parser.parse(invalidYaml),
        throwsA(isA<ConfigurationException>()),
      );
    });
  });
}
