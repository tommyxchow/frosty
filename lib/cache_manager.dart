import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CustomCacheManager {
  static const key = 'libCachedImageData';
  static final _repo = CacheObjectProvider(databaseName: key);
  static final instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 10000,
      repo: _repo,
    ),
  );

  static Future<void> removeOrphanedCacheFiles() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/$key');

    if (!await cacheDir.exists()) {
      return;
    }

    final allFiles = cacheDir.listSync(recursive: true).toList();

    await _repo.open();
    final cachedObjects = await _repo.getAllObjects();
    final dbFiles = cachedObjects.map((e) => e.relativePath).toSet();

    final orphanedFiles = allFiles.where((file) {
      final relativePath = file.path.split('$key/').last;
      return !dbFiles.contains(relativePath);
    }).toList();

    final deletions = orphanedFiles.map((file) => file.delete()).toList();

    try {
      await Future.wait(deletions);
      // ignore: empty_catches
    } catch (e) {}
  }
}
