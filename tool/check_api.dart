import 'dart:io';

import 'package:uts/services/cafe_service.dart';

/// Smoke check terhadap API asli. Memerlukan koneksi internet.
Future<void> main() async {
  final service = CafeService();
  try {
    final cafes = await service.fetchCafes();
    final areas = cafes.map((cafe) => cafe.area).toSet();
    stdout.writeln(
      'HTTP dan parsing model berhasil: ${cafes.length} kafe, ${areas.length} wilayah.',
    );
    if (cafes.isNotEmpty) stdout.writeln('Contoh: ${cafes.first.name}');
  } catch (error) {
    stderr.writeln('Pemeriksaan API gagal: $error');
    exitCode = 1;
  } finally {
    service.close();
  }
}
