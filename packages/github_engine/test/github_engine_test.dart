import 'package:github_engine/github_engine.dart';
import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('ReadmeGenerator tests', () {
    const generator = ReadmeGenerator();

    test('generates README markdown with badges, installation, and license',
        () {
      const config = MarketingConfig(
        appName: 'Expense AI',
        packageName: 'com.example.expense',
        outputDirectory: 'marketing',
        theme: 'modern',
        template: 'gaming',
        primaryColor: '#5E5CE6',
        accentColor: '#00C2FF',
        devices: ['pixel9'],
        languages: ['en'],
        screens: {
          'home': ScreenSpec(id: 'home', route: '/', title: 'Home'),
        },
      );

      final markdown = generator.generateReadme(config);

      expect(markdown, contains('# Expense AI'));
      expect(markdown, contains('[![pub package]'));
      expect(markdown, contains('## 🚀 Installation'));
      expect(markdown, contains('## 📄 License'));
      expect(markdown, contains('## 🤝 Contributing'));
    });
  });
}
