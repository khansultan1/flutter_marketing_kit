# flutter_marketing_kit

[![pub package](https://img.shields.io/pub/v/flutter_marketing_kit.svg)](https://pub.dev/packages/flutter_marketing_kit)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-222222.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**The World's Best Flutter Marketing Automation Toolkit.**

`flutter_marketing_kit` is a production-grade, offline-first developer toolkit designed to automatically capture app screenshots, composite high-fidelity device frames, generate feature graphics, format store assets, build social media previews, write GitHub documentation, and generate ASO copy.

---

## Features

- 🚀 **One-Command Asset Generation**: Run `dart run flutter_marketing_kit generate` to build all store & social assets.
- 📱 **Multi-Device Support**: Pixel 9, Pixel Fold, Galaxy S25, Galaxy Tab, iPhone 16, iPhone 16 Pro, iPhone SE, iPad, iPad Air, iPad Pro.
- 🎨 **Feature Graphic Generator**: 1024x500 play store feature graphics with preset templates (Modern, Minimal, Gaming, Kids, Finance, etc.).
- 🌐 **Offline-First & Privacy-Focused**: Core asset generation works 100% offline. No cloud account or paid API required.
- 🤖 **Optional AI Engine**: Connect Gemini, OpenAI, Anthropic, OpenRouter, Ollama, or LM Studio for automated copywriting & localization.
- 📦 **Melos Monorepo Architecture**: Clean architecture with modular engines.

---

## Quick Start

### 1. Initialize Configuration

```bash
dart run flutter_marketing_kit init
```

This creates a `playstore_assets.yaml` configuration file in your project root.

### 2. Generate Marketing Assets

```bash
dart run flutter_marketing_kit generate
```

---

## CLI Commands

| Command | Description |
| :--- | :--- |
| `init` | Initialize configuration file (`playstore_assets.yaml`) |
| `generate` | Generate all marketing assets |
| `screenshots` | Capture raw application screenshots |
| `frames` | Composite device frames onto screenshots |
| `feature-graphic` | Generate 1024x500 feature graphics |
| `templates` | List available asset templates |
| `devices` | List supported device frames and specs |
| `doctor` | Run diagnostic checks on project setup |
| `preview` | Generate device preview mockups |
| `resize` | Resize and process images |
| `clean` | Clean generated marketing artifacts |
| `version` | Display version information |
| `help` | Display usage instructions |

---

## License

[MIT License](LICENSE) © Flutter Marketing Kit Authors
