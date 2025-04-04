import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'imageCache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      // stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 50,
    ),
  );
}
