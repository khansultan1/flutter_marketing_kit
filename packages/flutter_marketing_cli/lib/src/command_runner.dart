import 'package:args/command_runner.dart';
import 'package:flutter_marketing_cli/src/commands/clean_command.dart';
import 'package:flutter_marketing_cli/src/commands/devices_command.dart';
import 'package:flutter_marketing_cli/src/commands/doctor_command.dart';
import 'package:flutter_marketing_cli/src/commands/feature_graphic_command.dart';
import 'package:flutter_marketing_cli/src/commands/frames_command.dart';
import 'package:flutter_marketing_cli/src/commands/generate_command.dart';
import 'package:flutter_marketing_cli/src/commands/init_command.dart';
import 'package:flutter_marketing_cli/src/commands/preview_command.dart';
import 'package:flutter_marketing_cli/src/commands/resize_command.dart';
import 'package:flutter_marketing_cli/src/commands/screenshots_command.dart';
import 'package:flutter_marketing_cli/src/commands/templates_command.dart';
import 'package:flutter_marketing_cli/src/commands/version_command.dart';

/// Command runner for flutter_marketing_kit CLI tool.
class MarketingCliCommandRunner extends CommandRunner<int> {
  /// Creates a [MarketingCliCommandRunner] and registers sub-commands.
  MarketingCliCommandRunner()
      : super(
          'flutter_marketing_kit',
          'Automated Marketing Toolkit & Asset Generator.',
        ) {
    addCommand(InitCommand());
    addCommand(GenerateCommand());
    addCommand(ScreenshotsCommand());
    addCommand(FramesCommand());
    addCommand(TemplatesCommand());
    addCommand(DevicesCommand());
    addCommand(FeatureGraphicCommand());
    addCommand(DoctorCommand());
    addCommand(PreviewCommand());
    addCommand(ResizeCommand());
    addCommand(CleanCommand());
    addCommand(VersionCommand());
  }
}
