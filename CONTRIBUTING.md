# Contributing to flutter_marketing_kit

Thank you for your interest in contributing to **`flutter_marketing_kit`**!

## Development Workflow

1. Fork and clone the repository.
2. Ensure latest stable Flutter and Dart SDKs are installed.
3. Install dependencies and bootstrap monorepo:
   ```bash
   melos bootstrap
   ```
4. Run static analysis:
   ```bash
   melos run analyze
   ```
5. Run tests across all packages:
   ```bash
   melos run test
   ```

## Pull Request Guidelines

- All PRs must pass `very_good_analysis` with 0 warnings or errors.
- Include unit tests for any new features or bug fixes.
- Follow Clean Architecture and SOLID principles.
