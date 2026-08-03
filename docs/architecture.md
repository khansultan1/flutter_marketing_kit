# Architecture Guide - flutter_marketing_kit

`flutter_marketing_kit` is designed as a modular Melos monorepo adhering strictly to Clean Architecture and SOLID principles.

## Package Layering & Engine Hierarchy

```
packages/
├── shared                  (Domain models, specs, color utilities, exceptions)
├── config_engine           (YAML loader, schema validator, template generator)
├── navigation_engine       (Route observer, state injection, route triggers)
├── screenshot_engine       (Drivers, retries, viewports, retina DPI scaling)
├── device_frame_engine     (Vector SVG mockups, bezels, shadows, corner radii)
├── image_engine            (Bitmap manipulation, gradients, filters, encoders)
├── feature_graphic_engine  (1024x500 play store compositor with templates)
├── store_engine            (App store resolution formatting across 5 platforms)
├── social_engine           (Social media dimensions: LinkedIn, X, IG, Threads, PH, GH)
├── template_engine         (Design themes, colors, typography, glassmorphism)
├── asset_export_engine     (Archiving, directory structure, SHA-256 checksums)
├── ai_engine               (Optional AI copywriters: Gemini, OpenAI, Claude, etc.)
├── github_engine           (Automated README, badges, installation docs)
├── flutter_marketing_cli   (Executable `args` command runner)
└── flutter_marketing_kit   (Facade wrapper package)
```
