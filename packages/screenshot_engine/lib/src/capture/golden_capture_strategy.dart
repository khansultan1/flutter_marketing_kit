import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:screenshot_engine/src/capture/harness_generator.dart';
import 'package:screenshot_engine/src/models/screenshot_options.dart';
import 'package:screenshot_engine/src/models/screenshot_result.dart';
import 'package:shared/shared.dart';

/// Captures real Flutter app screenshots by generating and running a widget
/// test harness inside the user's own project.
///
/// **Flow:**
/// 1. Generates `test/marketing_screenshots_test.dart` in the project root.
/// 2. Runs `flutter test … --update-goldens` from the project root.
/// 3. Flutter's test renderer boots the user's real app, navigates to each
///    configured route, and writes pixel-perfect PNGs to
///    `<outputDirectory>/raw_screenshots/<locale>/<device>/`.
/// 4. Returns a list of screenshot results pointing at those files.
class GoldenCaptureStrategy {
  /// Creates a [GoldenCaptureStrategy].
  const GoldenCaptureStrategy();

  /// Strategy name for logging.
  String get name => 'GoldenCaptureStrategy';

  /// Execute the full headless capture pipeline.
  ///
  /// [projectRoot] **must** be the root of the user's Flutter project —
  /// the directory that contains `pubspec.yaml` and `lib/main.dart`.
  /// Pass `Directory.current.path` from the CLI entry point.
  Future<List<ScreenshotResult>> captureWithHarness(
    MarketingConfig config, {
    required String projectRoot,
  }) async {
    // Validate: the projectRoot must be a Flutter project
    if (!File(p.join(projectRoot, 'pubspec.yaml')).existsSync()) {
      stderr.writeln(
        '❌ No pubspec.yaml found at $projectRoot.\n'
        '   Run this command from the root of your Flutter project.',
      );
      return [];
    }

    if (!File(p.join(projectRoot, 'lib', 'main.dart')).existsSync()) {
      stderr.writeln(
        '❌ No lib/main.dart found at $projectRoot.\n'
        '   Make sure you are running from your Flutter project root.',
      );
      return [];
    }

    const generator = HarnessGenerator();

    stdout.writeln(
      '   🔧 Generating test harness in'
      ' $projectRoot/test/...',
    );

    final harnessFile = await generator.generateHarnessScript(
      config: config,
      projectRoot: projectRoot,
    );

    final relativeTestPath =
        p.relative(harnessFile.path, from: projectRoot);

    stdout.writeln(
      '   ▶️  Running: flutter test $relativeTestPath'
      ' --update-goldens',
    );

    final processResult = await Process.run(
      'flutter',
      ['test', relativeTestPath, '--update-goldens'],
      workingDirectory: projectRoot,
      runInShell: true,
    );

    if (processResult.exitCode != 0) {
      stderr
        ..writeln(
          '❌ flutter test failed '
          '(exit code ${processResult.exitCode}).',
        )
        ..writeln()
        ..writeln('--- STDOUT ---')
        ..writeln(processResult.stdout)
        ..writeln('--- STDERR ---')
        ..writeln(processResult.stderr)
        ..writeln()
        ..writeln(
          'Fix the errors above, then re-run '
          '`dart run flutter_marketing_kit generate`.',
        );
      return [];
    }

    stdout.writeln('   ✅ All screens captured successfully.');

    // Build result list pointing at the written golden files
    final results = <ScreenshotResult>[];
    for (final lang in config.languages) {
      for (final deviceId in config.devices) {
        final deviceSpec = DeviceSpec.findById(deviceId);
        if (deviceSpec == null) continue;
        for (final entry in config.screens.entries) {
          final screenSpec = entry.value;
          final fileName = '${deviceSpec.id}_${entry.key}_$lang.png';
          final filePath = p.canonicalize(
            p.join(
              projectRoot,
              config.outputDirectory,
              'raw_screenshots',
              lang,
              deviceSpec.id,
              fileName,
            ),
          );

          results.add(
            ScreenshotResult.success(
              options: ScreenshotOptions(
                screenSpec: screenSpec,
                deviceSpec: deviceSpec,
                outputFilePath: filePath,
                locale: lang,
              ),
              filePath: filePath,
              captureDuration: Duration.zero,
            ),
          );
        }
      }
    }
    return results;
  }
}
