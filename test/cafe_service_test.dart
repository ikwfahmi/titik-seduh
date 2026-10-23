import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uts/models/cafe.dart';
import 'package:uts/services/cafe_service.dart';

void main() {
  test(
    'GET endpoint, UTF-8 JSON array, numeric fields, optional defaults',
    () async {
      final service = CafeService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url, CafeService.endpoint);
          expect(request.headers['Accept'], 'application/json');
          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {
                  'id': 12,
                  'name': 'Kopi énak',
                  'gmaps_rating': 4,
                  'gmaps_review_count': 51,
                  'verified': true,
                },
              ]),
            ),
            200,
          );
        }),
      );
      addTearDown(service.close);
      final result = await service.fetchCafes();
      expect(result.single.name, 'Kopi énak');
      expect(result.single.rating, 4.0);
      expect(result.single.reviewCount, 51);
      expect(result.single.priceLabel, 'Harga belum tersedia');
      expect(result.single.facilities, isEmpty);
      expect(result.single.verified, isTrue);
    },
  );
  test('empty API array is a valid result', () async {
    final service = CafeService(
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    addTearDown(service.close);
    expect(await service.fetchCafes(), isEmpty);
  });
  for (final status in [404, 429, 500]) {
    test('HTTP $status produces a readable API error', () async {
      final service = CafeService(
        client: MockClient((_) async => http.Response('error', status)),
      );
      addTearDown(service.close);
      await expectLater(
        service.fetchCafes(),
        throwsA(
          isA<CafeApiException>().having(
            (e) => e.message,
            'message',
            contains('$status'),
          ),
        ),
      );
    });
  }
  for (final body in ['<html>error</html>', '{}', '[null]', '[{"id":1}]']) {
    test('invalid payload $body is handled', () async {
      final service = CafeService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(service.close);
      await expectLater(service.fetchCafes(), throwsA(isA<CafeApiException>()));
    });
  }
  test('network failure is handled', () async {
    final service = CafeService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(service.close);
    await expectLater(
      service.fetchCafes(),
      throwsA(
        isA<CafeApiException>().having(
          (e) => e.message,
          'message',
          contains('internet'),
        ),
      ),
    );
  });
  test('timeout is handled', () async {
    final service = CafeService(
      client: MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 5),
    );
    addTearDown(service.close);
    await expectLater(
      service.fetchCafes(),
      throwsA(
        isA<CafeApiException>().having(
          (e) => e.message,
          'message',
          contains('terlalu lama'),
        ),
      ),
    );
  });
  test(
    'model handles null values, unrated cafes and validates required data',
    () {
      final cafe = Cafe.fromJson({
        'id': '5',
        'name': 'Kafe',
        'price_range': null,
        'gmaps_rating': 0,
        'facilities': null,
      });
      expect(cafe.rating, isNull);
      expect(cafe.ratingLabel, 'Belum dinilai');
      expect(cafe.mapsUri, isNull);
      expect(() => Cafe.fromJson({'name': 'Kafe'}), throwsFormatException);
    },
  );
  test('map URI rejects non-map URLs and uses coordinates as fallback', () {
    const cafe = Cafe(
      id: 1,
      name: 'Kafe',
      mapsUrl: 'javascript:alert(1)',
      latitude: -7.2,
      longitude: 112.7,
    );
    expect(cafe.mapsUri?.host, 'www.google.com');
    expect(cafe.mapsUri?.queryParameters['query'], '-7.2,112.7');
    expect(
      const Cafe(id: 2, name: 'Kafe', mapsUrl: 'https://example.com').mapsUri,
      isNull,
    );
  });
}
