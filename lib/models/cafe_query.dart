import 'cafe.dart';

enum CafeSort {
  reviews('Ulasan terbanyak'),
  rating('Rating tertinggi'),
  name('Nama A–Z');

  const CafeSort(this.label);
  final String label;
}

List<Cafe> filterCafes(
  List<Cafe> cafes, {
  String query = '',
  String? area,
  bool highlyRated = false,
  bool open24Hours = false,
  Set<int>? favoriteIds,
  CafeSort sort = CafeSort.reviews,
}) {
  final search = query.trim().toLowerCase();
  final result = cafes
      .where(
        (cafe) =>
            (search.isEmpty ||
                '${cafe.name} ${cafe.address} ${cafe.area} ${cafe.category}'
                    .toLowerCase()
                    .contains(search)) &&
            (area == null || cafe.area == area) &&
            (!highlyRated || (cafe.rating ?? 0) >= 4) &&
            (!open24Hours || (cafe.is24Hours && !cafe.isTemporarilyClosed)) &&
            (favoriteIds == null || favoriteIds.contains(cafe.id)),
      )
      .toList();
  result.sort((a, b) {
    final comparison = switch (sort) {
      CafeSort.reviews => b.reviewCount.compareTo(a.reviewCount),
      CafeSort.rating => (b.rating ?? -1).compareTo(a.rating ?? -1),
      CafeSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
    if (comparison != 0) return comparison;
    final reviews = b.reviewCount.compareTo(a.reviewCount);
    return reviews != 0 ? reviews : a.id.compareTo(b.id);
  });
  return result;
}
