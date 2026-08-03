import 'package:shared/shared.dart';

/// Generator for GitHub README markdown documents, badges, and documentation.
class ReadmeGenerator {
  /// Creates a [ReadmeGenerator] instance.
  const ReadmeGenerator();

  /// Generate full GitHub README markdown string based on [config].
  String generateReadme(MarketingConfig config) {
    final name = config.appName;
    final pkg = config.packageName;

    return '''
# $name

[![pub package](https://img.shields.io/pub/v/$pkg.svg)](https://pub.dev/packages/$pkg)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-222222.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An automated Flutter application designed for maximum performance and user satisfaction.

---

## 📱 Screenshots

${config.screens.entries.map((e) => '### ${e.value.title}\n*Route: `${e.value.route}`*').join('\n\n')}

---

## 🚀 Installation

Add to your Flutter `pubspec.yaml`:

```yaml
dependencies:
  $pkg: ^1.0.0
```

Run:

```bash
flutter pub get
```

---

## 💡 Usage

```dart
import 'package:$pkg/$pkg.dart';

void main() {
  print('Welcome to $name!');
}
```

---

## 📄 License

Licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).
''';
  }
}
