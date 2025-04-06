import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CustomCacheManager {
  static const key = 'libCachedImageData';
  static final repo = CacheObjectProvider(databaseName: key);
  //TODO: Change to 30 days and 500 objects
  static final instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 200,
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

    final allFiles = cacheDir.listSync(recursive: true).toList();

    await repo.open();
    final cachedObjects = await repo.getAllObjects();
    final dbFiles = cachedObjects.map((e) => e.relativePath).toSet();

    final orphanedFiles = allFiles.where((file) {
      final relativePath = file.path.split('$key/').last;
      return !dbFiles.contains(relativePath);
    }).toList();

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
