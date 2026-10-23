import 'package:flutter/material.dart';

import 'app.dart';
import 'services/favorites_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favorites = await FavoritesStore.load();
  runApp(TitikSeduhApp(favorites: favorites));
}
