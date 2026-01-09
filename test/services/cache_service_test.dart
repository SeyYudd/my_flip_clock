import 'package:flutter_test/flutter_test.dart';
import 'package:my_stand_clock/core/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    test('can cache and retrieve data', () async {
      final testData = {'key': 'value', 'number': 42};

      await cacheService.cache('test_key', testData);

      final retrieved = await cacheService.get('test_key');

      expect(retrieved, isNotNull);
      expect(retrieved!['key'], 'value');
      expect(retrieved['number'], 42);
    });

    test('returns null for non-existent cache', () async {
      final retrieved = await cacheService.get('non_existent');

      expect(retrieved, isNull);
    });

    test('respects cache expiry', () async {
      final testData = {'key': 'value'};

      await cacheService.cache(
        'expiring_key',
        testData,
        expiry: const Duration(milliseconds: 100),
      );

      // Should exist immediately
      var retrieved = await cacheService.get('expiring_key');
      expect(retrieved, isNotNull);

      // Wait for expiry
      await Future.delayed(const Duration(milliseconds: 150));

      // Should be null after expiry
      retrieved = await cacheService.get('expiring_key');
      expect(retrieved, isNull);
    });

    test('can clear specific cache', () async {
      await cacheService.cache('test_key', {'data': 'value'});

      await cacheService.clear('test_key');

      final retrieved = await cacheService.get('test_key');
      expect(retrieved, isNull);
    });
  });
}
