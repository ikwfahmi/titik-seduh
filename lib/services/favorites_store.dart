import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._preferences)
    : _ids = (_preferences.getStringList(_key) ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  static const _key = 'titik_seduh_favorite_ids';
  final SharedPreferences _preferences;
  Set<int> _ids;
  bool _saving = false;

  static Future<FavoritesStore> load() async =>
      FavoritesStore(await SharedPreferences.getInstance());
  Set<int> get ids => Set.unmodifiable(_ids);
  bool contains(int id) => _ids.contains(id);

  Future<void> toggle(int id) async {
    if (_saving) return;
    _saving = true;
    final updated = {..._ids};
    updated.contains(id) ? updated.remove(id) : updated.add(id);
    try {
      final success = await _preferences.setStringList(
        _key,
        updated.map((e) => '$e').toList(),
      );
      if (!success) throw StateError('Favorit belum berhasil disimpan.');
      _ids = updated;
      notifyListeners();
    } finally {
      _saving = false;
    }
  }
}
