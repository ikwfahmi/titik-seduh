import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/cafe_service.dart';
import 'services/favorites_store.dart';
import 'theme/app_theme.dart';

class TitikSeduhApp extends StatelessWidget {
  const TitikSeduhApp({super.key, required this.favorites, this.service});
  final FavoritesStore favorites;
  final CafeService? service;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Titik Seduh',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: HomeScreen(favorites: favorites, service: service),
  );
}
