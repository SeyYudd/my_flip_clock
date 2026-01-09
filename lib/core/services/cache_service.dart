import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/error_handler.dart';

/// Generic cache service for storing data locally
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// Cache data with expiry time
  Future<void> cache(
    String key,
    Map<String, dynamic> data, {
    Duration? expiry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (expiry != null) 'expiry': expiry.inMilliseconds,
      };

      await prefs.setString('cache_$key', jsonEncode(cacheData));
    } catch (e) {
      ErrorHandler().handleApiError('CacheService.cache', e);
    }
  }

  /// Get cached data if not expired
  Future<Map<String, dynamic>?> get(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_$key');

      if (cached == null) return null;

      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int?;

      if (expiry != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > expiry) {
          await clear(key);
          return null;
        }
      }

      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      ErrorHandler().handleApiError('CacheService.get', e);
      return null;
    }
  }

  /// Check if cache exists and is valid
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Clear specific cache
  Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$key');
    } catch (e) {
      ErrorHandler().handleApiError('CacheService.clear', e);
    }
  }

  /// Clear all caches
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      ErrorHandler().handleApiError('CacheService.clearAll', e);
    }
  }

  /// Get cache age in milliseconds
  Future<int?> getCacheAge(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_$key');

      if (cached == null) return null;

      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;

      return DateTime.now().millisecondsSinceEpoch - timestamp;
    } catch (e) {
      return null;
    }
  }
}
