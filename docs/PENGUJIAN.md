# Hasil pengujian Titik Seduh

Tanggal: 23 Oktober 2026. Flutter 3.47.7 stable, Dart 3.13.5. Antarmuka menggunakan gaya kartun dengan warna krem dan cokelat.

## Pengujian otomatis

`flutter analyze`: **No issues found**. `flutter test`: **29 pengujian lulus** setelah perubahan UI. Skenario HTTP menggunakan MockClient agar respons error, timeout, dan JSON rusak dapat direproduksi tanpa mengganggu API asli.

| Kelompok | Jumlah | Bukti yang diperiksa |
| --- | ---: | --- |
| Service API dan model | 13 | GET endpoint, header JSON, UTF-8, array kosong, HTTP 404/429/500, HTML/objek/null/rekaman invalid, kegagalan jaringan, timeout, atribut opsional, URL peta |
| Pencarian/filter/sort | 5 | Pencarian tanpa membedakan kapital, kombinasi filter, rating kosong, tiga pengurutan, hasil kosong |
| Penyimpanan favorit | 2 | Simpan, muat store baru, hapus, dan abaikan ID tersimpan yang rusak |
| Widget dan navigasi | 9 | Loading→sukses, error→retry→sukses, pencarian tanpa HTTP tambahan, filter, detail→favorit, data kosong, teks besar, lebar 320 dan 1100 |

Angka service/model mencakup skenario yang diparameterkan. Test UI memakai data contoh yang terkontrol; data tersebut bukan pengganti API pada aplikasi produksi.

## Integrasi API asli

Perintah `dart run tool/check_api.dart` menggunakan service dan model produksi. Hasil aktual:

```text
HTTP dan parsing model berhasil: 874 kafe, 5 wilayah.
Contoh: Kollabora | The Best Thematic Cafe & Restaurant in Indonesia
```

Flutter Web versi awal telah memuat 874 data dari endpoint asli, menemukan satu hasil untuk Kollabora, membuka detail, dan menampilkan kafe pada koleksi favorit. Screenshot berlabel `web` adalah versi UI awal; screenshot Android menampilkan UI kartun terbaru.

Pada Android API 34 emulator Pixel, APK debug berhasil dipasang dan UI final menampilkan 874 data dari API asli. Screenshot Android ada pada folder `screenshots/`. Daftar, pencarian, detail, dan favorit diperiksa melalui UI aplikasi, bukan halaman mockup.

## Pemeriksaan build release

Pengujian runtime menemukan `NoSuchMethodError` pada plugin shared_preferences_android 2.5.0 saat startup release. Dependency diperbarui ke 2.5.3 yang membawa aturan R8 resmi. Lihat [changelog plugin](https://pub.dev/packages/shared_preferences_android/changelog). Tombol peta pada release juga berhasil mengirim intent HTTPS lokasi Kampung Kecil Wiyung ke Google Maps (`com.google.android.apps.maps`). APK dibangun ulang dari cache bersih setelah pembaruan. Versi release berhasil memuat 874 kafe, dan favorit Kampung Kecil Wiyung tetap muncul setelah aplikasi dipasang serta dibuka ulang.

## Cara mengulangi

```bash
flutter pub get
flutter analyze
flutter test
# Memerlukan internet dan API yang tersedia:
dart run tool/check_api.dart
flutter build apk --debug
flutter run -d <id-perangkat>
```

Periksa loading saat membuka aplikasi, cari nama kafe, pilih wilayah dan rating, buka detail, simpan favorit, lalu kunjungi tab Favorit. Muat ulang memakai ikon refresh atau tarik daftar ke bawah. Tombol peta memakai Google Maps dari data API; ketersediaan aplikasi peta/browser mengikuti perangkat.

## Batas pemeriksaan

Build dan pemeriksaan runtime dilakukan pada Android emulator API 34 serta Flutter Web. Build iOS/macOS/Windows tidak dijalankan di lingkungan Linux ini. Pengujian pada ponsel fisik belum dilakukan. Tidak ada pengukuran performa, audit API, atau jaminan kebenaran isi data penyedia API.
