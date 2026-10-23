import 'package:flutter_test/flutter_test.dart';
import 'package:uts/models/cafe.dart';
import 'package:uts/models/cafe_query.dart';

const cafes = [
  Cafe(
    id: 1,
    name: 'Kopi Taman',
    area: 'Surabaya Barat',
    address: 'Jl. Mawar',
    rating: 4.2,
    reviewCount: 100,
    openingHours: 'Buka 24 jam',
  ),
  Cafe(
    id: 2,
    name: 'Sudut Kota',
    area: 'Surabaya Timur',
    rating: 4.8,
    reviewCount: 30,
  ),
  Cafe(id: 3, name: 'Angkringan', area: 'Surabaya Barat', reviewCount: 5),
  Cafe(
    id: 4,
    name: 'Kopi Tutup',
    area: 'Surabaya Barat',
    rating: 4.9,
    openingHours: 'Buka 24 jam',
    status: 'Temporarily closed',
  ),
];
void main() {
  test('case insensitive search on name, address, area', () {
    expect(filterCafes(cafes, query: '  MAWAR ').single.id, 1);
    expect(filterCafes(cafes, query: 'timur').single.id, 2);
  });
  test('area, rating, 24h and favorites filters compose', () {
    final result = filterCafes(
      cafes,
      area: 'Surabaya Barat',
      highlyRated: true,
      open24Hours: true,
      favoriteIds: {1, 2, 4},
    );
    expect(result.map((e) => e.id), [1]);
  });
  test('unknown ratings are excluded by minimum rating', () {
    expect(
      filterCafes(cafes, highlyRated: true).map((e) => e.id),
      isNot(contains(3)),
    );
  });
  test('sorts by reviews, rating and name without mutating source', () {
    expect(filterCafes(cafes).first.id, 1);
    expect(filterCafes(cafes, sort: CafeSort.rating).first.id, 4);
    expect(filterCafes(cafes, sort: CafeSort.name).first.id, 3);
    expect(cafes.first.id, 1);
  });
  test('unmatched query and empty favorites return no results', () {
    expect(filterCafes(cafes, query: 'tidakada'), isEmpty);
    expect(filterCafes(cafes, favoriteIds: {}), isEmpty);
  });
}
