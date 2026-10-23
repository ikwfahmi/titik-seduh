import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts/services/favorites_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'favorites persist when a new store is loaded and can be removed',
    () async {
      final store = await FavoritesStore.load();
      await store.toggle(42);
      final reloaded = await FavoritesStore.load();
      expect(reloaded.contains(42), isTrue);
      await reloaded.toggle(42);
      expect((await FavoritesStore.load()).ids, isEmpty);
    },
  );
  test('invalid stored IDs are ignored', () async {
    SharedPreferences.setMockInitialValues({
      'titik_seduh_favorite_ids': ['abc', '42'],
    });
    expect((await FavoritesStore.load()).ids, {42});
  });
}
