import 'dart:io';

import 'package:args/command_runner.dart';

/// CLI Command to list all supported asset templates.
class TemplatesCommand extends Command<int> {
  @override
  String get name => 'templates';

  @override
  String get description => 'List available visual templates and themes.';

  @override
  Future<int> run() async {
    stdout
      ..writeln('🎨 Available Visual Templates:')
      ..writeln(
        '  - modern   : Clean, glassmorphism overlays and vibrant gradients.',
      )
      ..writeln(
        '  - minimal  : Sleek monochromatic aesthetics with drop shadows.',
      )
      ..writeln(
        '  - material : Dynamic Material 3 design system styling.',
      )
      ..writeln(
        '  - gaming   : High-contrast neon accents and dark backgrounds.',
      )
      ..writeln(
        '  - kids     : Playful rounded geometry, pastel colors, and badges.',
      )
      ..writeln(
        '  - finance  : Professional corporate layouts with subtle gridlines.',
      )
      ..writeln(
        '  - health   : Calming organic color gradients & serene typography.',
      )
      ..writeln(
        '  - education: Structurally aligned blocks with highlight banners.',
      );
    return 0;
  }
}
