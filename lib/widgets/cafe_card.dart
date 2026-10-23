import 'package:flutter/material.dart';

import '../models/cafe.dart';
import '../services/favorites_store.dart';
import '../theme/app_theme.dart';
import 'coffee_art.dart';
import 'favorite_button.dart';

class CafeCard extends StatelessWidget {
  const CafeCard({
    super.key,
    required this.cafe,
    required this.favorites,
    required this.onTap,
  });
  final Cafe cafe;
  final FavoritesStore favorites;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: const BorderSide(color: AppTheme.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 11, 11, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  height: 75,
                  margin: const EdgeInsets.only(right: 12, top: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.peach.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: CoffeeArt(size: 65, takeaway: cafe.id.isEven),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cafe.category.isEmpty ? 'Kafe' : cafe.category,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          cafe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          cafe.areaLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                FavoriteButton(id: cafe.id, store: favorites),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 11),
            Wrap(
              spacing: 12,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppTheme.tan,
                    ),
                    Text(
                      cafe.ratingLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '(${cafe.reviewCount} ulasan)',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  cafe.priceLabel,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 11),
                ),
                if (cafe.isTemporarilyClosed)
                  const Text(
                    'Tutup sementara',
                    style: TextStyle(fontSize: 11, color: AppTheme.orange),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
