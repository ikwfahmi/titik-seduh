import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts/app.dart';
import 'package:uts/services/cafe_service.dart';
import 'package:uts/services/favorites_store.dart';

final verticalScroll = find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

const payload = '''[
 {"id":1,"name":"Kopi Taman","area":"Surabaya Barat","gmaps_rating":4.5,"gmaps_review_count":100,"address":"Jl. Mawar","opening_hours":"Buka 24 jam"},
 {"id":2,"name":"Sudut Kota","area":"Surabaya Timur","gmaps_rating":3,"gmaps_review_count":10}
]''';

Future<void> launch(
  WidgetTester tester,
  http.Client client, {
  Size size = const Size(390, 844),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  SharedPreferences.setMockInitialValues({});
  final store = await FavoritesStore.load();
  final service = CafeService(client: client);
  addTearDown(service.close);
  await tester.pumpWidget(TitikSeduhApp(favorites: store, service: service));
}

void main() {
  testWidgets('FutureBuilder shows loading then API results', (tester) async {
    final response = Completer<http.Response>();
    await launch(tester, MockClient((_) => response.future));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    response.complete(http.Response(payload, 200));
    await tester.pumpAndSettle();
    expect(find.text('2 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kopi Taman'),
      150,
      scrollable: verticalScroll,
    );
    expect(find.text('Kopi Taman'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('error has retry which sends a new request and recovers', (
    tester,
  ) async {
    var requests = 0;
    await launch(
      tester,
      MockClient(
        (_) async => ++requests == 1
            ? http.Response('', 500)
            : http.Response(payload, 200),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Coba lagi'),
      200,
      scrollable: verticalScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(requests, 2);
    await tester.scrollUntilVisible(
      find.text('Kopi Taman'),
      150,
      scrollable: verticalScroll,
    );
    expect(find.text('Kopi Taman'), findsOneWidget);
  });
  testWidgets('search and clear do not repeat HTTP requests', (tester) async {
    var requests = 0;
    await launch(
      tester,
      MockClient((_) async {
        requests++;
        return http.Response(payload, 200);
      }),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('0 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('2 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
    expect(requests, 1);
  });
  testWidgets('area and rating filters update count', (tester) async {
    await launch(tester, MockClient((_) async => http.Response(payload, 200)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Timur'));
    await tester.tap(find.text('Timur'));
    await tester.pumpAndSettle();
    expect(find.text('1 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
    await tester.tap(find.text('Rating 4+'));
    await tester.pumpAndSettle();
    expect(find.text('0 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
  });
  testWidgets('detail route, save favorite, return and view collection', (
    tester,
  ) async {
    await launch(tester, MockClient((_) async => http.Response(payload, 200)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Kopi Taman'),
      150,
      scrollable: verticalScroll,
    );
    await tester.tap(find.text('Kopi Taman'));
    await tester.pumpAndSettle();
    expect(find.text('Detail kafe'), findsOneWidget);
    await tester.tap(find.byTooltip('Simpan ke favorit'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('1 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kopi Taman'),
      150,
      scrollable: verticalScroll,
    );
    await tester.pumpAndSettle();
    expect(find.text('Kopi Taman'), findsOneWidget);
  });
  testWidgets('empty API and empty favorites are explained', (tester) async {
    await launch(tester, MockClient((_) async => http.Response('[]', 200)));
    await tester.pumpAndSettle();
    expect(find.text('0 tempat ditemukan · Ulasan terbanyak'), findsOneWidget);
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada kafe favorit'), findsOneWidget);
  });
  testWidgets('large text on narrow screen remains usable', (tester) async {
    await launch(
      tester,
      MockClient((_) async => http.Response(payload, 200)),
      size: const Size(320, 740),
      scale: 2,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Kopi Taman'),
      150,
      scrollable: verticalScroll,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kopi Taman'));
    await tester.pumpAndSettle();
  });
  for (final size in [const Size(320, 740), const Size(1100, 900)]) {
    testWidgets('responsive layout at ${size.width}', (tester) async {
      await launch(
        tester,
        MockClient((_) async => http.Response(payload, 200)),
        size: size,
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Kopi Taman'),
        120,
        scrollable: verticalScroll,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Kopi Taman'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
