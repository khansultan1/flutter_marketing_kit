import 'dart:io';

import 'package:asset_export_engine/asset_export_engine.dart';
import 'package:test/test.dart';

void main() {
  group('AssetExporter tests', () {
    const exporter = AssetExporter();

    test('calculates SHA-256 checksum for file', () async {
      final file = File('test_export/sample.txt');
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      await file.writeAsString('Flutter Marketing Kit Test');

      final checksum = await exporter.calculateChecksum(file);
      expect(checksum, isNotEmpty);
      expect(checksum.length, equals(64));

      if (file.parent.existsSync()) {
        file.parent.deleteSync(recursive: true);
      }
    });

    test('compresses directory into zip package', () async {
      final sampleDir = Directory('test_zip_src');
      final file = File('test_zip_src/item.txt');
      if (!sampleDir.existsSync()) {
        sampleDir.createSync(recursive: true);
      }
      await file.writeAsString('Zip payload content');

      final zipFile = await exporter.compressToZip(
        sourceDir: sampleDir,
        zipPath: 'test_out/package.zip',
      );

      expect(zipFile.existsSync(), isTrue);

      if (sampleDir.existsSync()) sampleDir.deleteSync(recursive: true);
      final outDir = Directory('test_out');
      if (outDir.existsSync()) outDir.deleteSync(recursive: true);
    });
  });
}
