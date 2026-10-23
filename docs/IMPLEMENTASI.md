# Catatan implementasi Titik Seduh

Dokumen ini menjadi bahan teknis untuk menyusun laporan pada kerangka UTS yang disediakan. Tangkapan layar ada di folder `screenshots/`; hasil pengujian terpisah ada di `PENGUJIAN.md`.

## Gambaran aplikasi dan tujuan

Titik Seduh membantu mahasiswa, warga, dan pengunjung Surabaya menemukan kafe berdasarkan wilayah, rating, jumlah ulasan, dan kisaran harga. Pengguna dapat mencari tempat, memeriksa detailnya, menyimpan favorit, lalu membuka lokasinya melalui Google Maps. Seluruh informasi kafe berasal dari Surabaya Cafe API; aplikasi tidak menyediakan akun, pemesanan, ulasan baru, atau perubahan data server.

## Persiapan project

Project dibuat dengan nama aplikasi **TITIK SEDUH** menggunakan Flutter dan Dart. Package tambahan: `http` untuk GET dan pengujian HTTP, `shared_preferences` untuk penyimpanan ID favorit, serta `url_launcher` untuk membuka peta. `flutter_test` dan `flutter_lints` dipakai untuk verifikasi. Perintah menjalankan, build, serta struktur folder lengkap tersedia pada README.

## Desain antarmuka

Tema menggunakan latar krem, teks cokelat, dan aksen terakota lembut. Halaman utama memuat identitas aplikasi, ilustrasi dekoratif, pencarian, filter wilayah, filter rating/24 jam, pengurutan, dan daftar kartu. Navigasi bawah berpindah antara Jelajahi dan Favorit. Pada layar lebar kartu menjadi grid; pada ponsel menjadi daftar vertikal. Halaman detail dibuka menggunakan Navigator dan MaterialPageRoute.

Gambar yang dapat digunakan pada subbab 2.2 laporan:

1. **Gambar 2.1 Halaman Jelajahi** — `screenshots/01-beranda-android.png`: daftar dinamis dan kontrol pencarian/filter. Jumlah tempat mengikuti respons API.
2. **Gambar 2.2 Hasil pencarian kafe** — `screenshots/03-pencarian-android.png`: pencarian Kollabora menghasilkan satu tempat dari data API pada saat pengujian.
3. **Gambar 2.3 Halaman detail kafe** — `screenshots/04-detail-android.png`: nama lengkap, rating, harga, alamat, informasi jam, dan tombol peta.
4. **Gambar 2.4 Halaman Favorit** — `screenshots/05-favorit-android.png`: kafe yang disimpan pada perangkat dan tetap tersedia setelah aplikasi dibuka kembali.

Screenshot laporan berasal dari aplikasi Android pada emulator API 34 resolusi 1080 × 1920. Tampilan mengikuti referensi pengguna dengan gerobak kopi kartun dan pola biji kopi yang digambar lokal. Screenshot berlabel `web` merupakan versi UI awal dan tidak digunakan pada laporan final.

## Struktur API

URL: `https://surabaya-cafe-api.vercel.app/api/cafes`, metode GET, respons berupa array JSON. Contoh ringkas satu rekaman aktual saat pemeriksaan 23 Oktober 2026:

```json
[
  {
    "id": 1944265036,
    "name": "'DUDU_Zone' CAFE",
    "category": "Kafe",
    "area": "Surabaya Barat",
    "address": "Jl. Tandes Lor Gg. Lebar No.88a",
    "latitude": -7.2611348,
    "longitude": 112.6869688,
    "price_range": "",
    "opening_hours": "Tutup pukul 23.30",
    "facilities": [],
    "gmaps_rating": 3,
    "gmaps_review_count": 2,
    "verified": true
  }
]
```

Contoh dipersingkat untuk pembahasan; respons lengkap juga memuat atribut lain seperti URL Google Maps, status operasional, dan tanggal verifikasi. Pada pemeriksaan tersebut terdapat 874 rekaman. Semua atribut deskripsi dan fasilitas kosong, sehingga aplikasi menampilkan keterangan fasilitas belum tersedia serta menyembunyikan bagian deskripsi yang kosong.

## Pengambilan dan pengolahan

Potongan berikut berasal dari service aplikasi. `await` menunggu respons tanpa memblokir antarmuka. Timeout membatasi waktu tunggu, status HTTP diperiksa sebelum parsing, dan model mengubah nama kolom JSON menjadi atribut Dart.

```dart
final response = await _client.get(
  endpoint,
  headers: {'Accept': 'application/json'},
).timeout(timeout);
if (response.statusCode != 200) {
  throw CafeApiException(
    'Server belum dapat memuat data (HTTP ${response.statusCode}). Silakan coba lagi.',
  );
}
final json = jsonDecode(utf8.decode(response.bodyBytes));
```

Setelah validasi array dan objek, setiap elemen diteruskan ke `Cafe.fromJson`. Model mewajibkan ID dan nama yang valid, mengonversi angka dengan aman, memproses daftar fasilitas, serta memberi nilai kosong pada atribut opsional. Rating nol dianggap belum dinilai. Lihat `lib/models/cafe.dart` dan `lib/services/cafe_service.dart` untuk kode lengkap yang menjadi sumber pembahasan.

## Asynchronous programming dan FutureBuilder

`_cafes = _service.fetchCafes()` dijalankan di `initState`, bukan di `build`. Future disimpan agar pencarian dan perubahan filter tidak mengulang HTTP. `FutureBuilder<List<Cafe>>` pada `home_screen.dart` menentukan tampilan berdasarkan snapshot:

| Kondisi | Tampilan |
| --- | --- |
| ConnectionState belum done | Indikator loading dan pesan menunggu |
| hasError | Pesan sesuai masalah dan tombol Coba lagi |
| Sukses dengan data | Kartu hasil filter dan pengurutan |
| Sukses tetapi hasil kosong | Jumlah nol dan penjelasan/resets |

Penggantian Future dilakukan secara sinkron di `setState` setelah request baru dibuat. Request ditunggu di luar `setState` agar callback tidak mengembalikan Future. Retry dan RefreshIndicator menggunakan proses yang sama.

```dart
final request = _service.fetchCafes();
setState(() {
  _cafes = request;
});
try {
  await request;
} catch (_) {
  // FutureBuilder menampilkan error kepada pengguna.
}
```

## Pemrosesan di perangkat

`filterCafes` menggabungkan pencarian tanpa membedakan huruf besar/kecil dengan filter wilayah, rating 4+, teks 24 jam, dan daftar favorit jika tab Favorit aktif. Hasil diurutkan pada salinan daftar sehingga respons asli tidak berubah. Rating yang sama diurutkan lagi menurut jumlah ulasan lalu ID agar hasil konsisten.

Favorit menyimpan daftar ID melalui SharedPreferences. Tampilan diperbarui setelah penyimpanan berhasil. `ListenableBuilder` mendengarkan perubahan untuk menyamakan ikon di kartu dan detail. Kegagalan penyimpanan diberi pesan; data lengkap kafe tetap dimuat dari jaringan.

## Peta dan batasan

Tombol peta membuka URL HTTPS Google Maps dari model. Jika URL tidak valid, model dapat membuat URL pencarian berdasarkan koordinat. Jika aplikasi peta gagal dibuka, Snackbar menawarkan penyalinan tautan. Data jam tidak dihitung sebagai status buka sekarang karena API hanya menyediakan teks dan tidak menyediakan jadwal terstruktur.

## Kesimpulan dan pengembangan lanjutan

Aplikasi telah menyediakan GUI, pengambilan HTTP asinkron, konversi JSON melalui model, tampilan data API, serta penanganan loading/sukses/error menggunakan FutureBuilder. Bukti keberhasilan harus mengacu pada hasil aktual di PENGUJIAN.md. Pengembangan selanjutnya dapat menambahkan cache offline, sinkronisasi favorit, foto yang disediakan sumber, dan jadwal terstruktur untuk perhitungan status buka.

Daftar pustaka dapat memakai referensi resmi yang tertera di README.
