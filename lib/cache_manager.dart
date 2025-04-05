import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CustomCacheManager {
  static const key = 'libCachedImageData';
  static final repo = CacheObjectProvider(databaseName: key);
  static final instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 50,
      repo: repo,
    ),
  );

  static Future<void> removeOrphanedCacheFiles() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/$key');

    if (!await cacheDir.exists()) {
      print("No cache directory found.");
      return;
    }

    // 1. Get list of files in file system
    final allFiles =
        cacheDir.listSync(recursive: true).whereType<File>().toList();

    // 2. Get all cached file paths from DB
    await repo.open();
    final cachedObjects = await repo.getAllObjects();
    final dbFiles = cachedObjects.map((e) => e.relativePath).toSet();

    // 3. Find orphaned files (on disk but not in DB)
    final orphanedFiles = allFiles.where((file) {
      final relativePath = file.path.split('$key/').last;
      return !dbFiles.contains(relativePath);
    }).toList();

    // 4. Delete them
    for (final file in orphanedFiles) {
      try {
        await file.delete();
        print('Deleted orphaned file: ${file.path}');
      } catch (e) {
        print('Failed to delete: ${file.path} — $e');
      }
    }

    print('Cleanup complete. Removed ${orphanedFiles.length} orphaned files.');
  }
}
