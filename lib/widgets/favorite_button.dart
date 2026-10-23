import 'package:flutter/material.dart';

import '../services/favorites_store.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.id, required this.store});
  final int id;
  final FavoritesStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => IconButton(
      tooltip: store.contains(id) ? 'Hapus dari favorit' : 'Simpan ke favorit',
      icon: Icon(
        store.contains(id)
            ? Icons.bookmark_rounded
            : Icons.bookmark_border_rounded,
      ),
      color: store.contains(id) ? AppTheme.orange : AppTheme.ink,
      onPressed: () async {
        try {
          await store.toggle(id);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Favorit belum tersimpan. Silakan coba lagi.'),
              ),
            );
          }
        }
      },
    ),
  );
}
