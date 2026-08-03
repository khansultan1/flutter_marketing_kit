import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Asset exporter service for directory archiving, checksums, and ZIP outputs.
class AssetExporter {
  /// Creates an [AssetExporter] instance.
  const AssetExporter();

  /// Calculate SHA-256 checksum string for a file on disk.
  Future<String> calculateChecksum(File file) async {
    if (!file.existsSync()) return '';
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Archive an entire output directory into a `.zip` package.
  Future<File> compressToZip({
    required Directory sourceDir,
    required String zipPath,
  }) async {
    final zipFile = File(p.canonicalize(zipPath));
    if (!zipFile.parent.existsSync()) {
      zipFile.parent.createSync(recursive: true);
    }

    final zipEncoder = ZipFileEncoder()..create(zipFile.path);
    await zipEncoder.addDirectory(sourceDir);
    await zipEncoder.close();

    return zipFile;
  }
}
