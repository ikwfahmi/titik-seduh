import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cafe.dart';
import '../services/favorites_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coffee_art.dart';
import '../widgets/favorite_button.dart';

class CafeDetailScreen extends StatelessWidget {
  const CafeDetailScreen({
    super.key,
    required this.cafe,
    required this.favorites,
  });
  final Cafe cafe;
  final FavoritesStore favorites;

  Future<void> _openMap(BuildContext context) async {
    final uri = cafe.mapsUri;
    if (uri == null) return;
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      /* Tawarkan tautan yang dapat disalin jika peluncur gagal. */
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Peta belum bisa dibuka.'),
        action: SnackBarAction(
          label: 'Salin tautan',
          onPressed: () => Clipboard.setData(ClipboardData(text: '$uri')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Detail kafe',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        FavoriteButton(id: cafe.id, store: favorites),
        const SizedBox(width: 12),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.peach,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const CoffeePattern(
                child: Center(child: CoffeeArt(size: 165)),
              ),
            ),
            const SizedBox(height: 25),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _badge(cafe.category.isEmpty ? 'Kafe' : cafe.category),
                if (cafe.verified)
                  _badge('Terverifikasi API', icon: Icons.verified_outlined),
                if (cafe.isTemporarilyClosed)
                  _badge('Tutup sementara', icon: Icons.info_outline),
              ],
            ),
            const SizedBox(height: 14),
            SelectableText(
              cafe.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(cafe.areaLabel, style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.line),
              ),
              child: Wrap(
                spacing: 28,
                runSpacing: 16,
                children: [
                  _stat(
                    Icons.star_rounded,
                    cafe.ratingLabel,
                    '${cafe.reviewCount} ulasan Google Maps',
                  ),
                  _stat(
                    Icons.payments_outlined,
                    cafe.priceLabel,
                    'Kisaran harga dari API',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Kenali tempatnya',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            _info(
              Icons.location_on_outlined,
              'Alamat',
              cafe.address.isEmpty ? 'Alamat belum tersedia.' : cafe.address,
            ),
            _info(
              Icons.schedule_rounded,
              'Informasi jam',
              cafe.openingHours.isEmpty
                  ? 'Jam operasional belum tersedia.'
                  : cafe.openingHours,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 40, bottom: 18),
              child: Text(
                'Informasi jam mengikuti data API, bukan status buka secara langsung.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.muted,
                  height: 1.5,
                ),
              ),
            ),
            if (cafe.description.isNotEmpty)
              _info(Icons.notes_rounded, 'Tentang kafe', cafe.description),
            _info(
              Icons.chair_outlined,
              'Fasilitas',
              cafe.facilities.isEmpty
                  ? 'Informasi fasilitas belum tersedia dari API.'
                  : cafe.facilities.join(' · '),
            ),
            if (cafe.needsTags.isNotEmpty)
              _info(
                Icons.sell_outlined,
                'Cocok untuk',
                cafe.needsTags.join(' · '),
              ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Sumber: Surabaya Cafe API${cafe.lastVerifiedAt == null ? '' : '\nVerifikasi data: ${_date(cafe.lastVerifiedAt!)}'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 712),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: cafe.mapsUri == null
                    ? null
                    : () => _openMap(context),
                icon: const Icon(Icons.near_me_outlined, size: 20),
                label: const Text('Buka di Google Maps'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Widget _badge(String text, {IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFF5E9DA),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: AppTheme.ink),
          const SizedBox(width: 5),
        ],
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _stat(IconData icon, String value, String caption) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppTheme.orange, size: 24),
      const SizedBox(width: 10),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 3),
            Text(
              caption,
              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _info(IconData icon, String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: AppTheme.muted),
        const SizedBox(width: 19),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: const TextStyle(color: AppTheme.muted, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
