# Cross check ketentuan UTS TITIK SEDUH

Diperiksa pada 23 Oktober 2026 dengan mencocokkan soal **UTS Pemrograman Mobile (1).pdf**, isi laporan final, source code, dan bukti pengujian yang tersedia. Laporan hasil revisi berjumlah **16 halaman**. Lokasi subbab tetap menjadi acuan jika halaman berubah.

Peta halaman: cover 1; BAB I 2; persiapan/struktur project 3–4; UI 5–6; URL/HTTP 7; JSON 8; model 9; async 10; penyajian UI 11; FutureBuilder dan status 12–13; pengujian 14; BAB III 15; daftar pustaka 16.

## Cover

| Ketentuan | Bukti dalam laporan | Status |
| --- | --- | --- |
| Judul laporan/nama aplikasi | LAPORAN UTS PEMROGRAMAN MOBILE dan TITIK SEDUH | Ada |
| Nama mata kuliah | Pemrograman Mobile pada judul | Ada |
| Logo pada cover | Logo dari template UTS.docx dipertahankan sesuai konfirmasi pengguna; nama Fakultas Sains dan Teknologi tercantum pada cover | Sesuai konfirmasi |
| Nama dan NIM | M. IKHWAN FAHMI — 240605110116; kelas C | Ada |
| Jurusan | Teknik Informatika sesuai identitas template | Ada |
| Perguruan tinggi | UIN Maulana Malik Ibrahim Malang | Ada |
| Tahun | GANJIL 2026/2027 | Ada |

Pengguna telah mengonfirmasi penggunaan logo dari template UTS.docx pada 23 Oktober 2026. Cover mengikuti pilihan tersebut.

## BAB I PENDAHULUAN

| Ketentuan | Lokasi dan isi yang diperiksa | Status |
| --- | --- | --- |
| Permasalahan/kebutuhan | 1.1: kebutuhan menelusuri dan membandingkan kafe Surabaya | Lengkap |
| Tujuan pengembangan | 1.1: panduan kafe serta penerapan GUI, HTTP, JSON/model, asynchronous | Lengkap |
| Sasaran pengguna | 1.1: mahasiswa, warga, dan pengunjung Surabaya | Lengkap |
| Gambaran fungsi aplikasi | 1.1: pencarian, detail, favorit, dan Google Maps | Lengkap |
| Fitur, fungsi, dan manfaat | 1.2: perbandingan tempat, mempersempit pilihan, pemeriksaan tujuan, menemukan kembali favorit, informasi status pemuatan | Lengkap |

## BAB II PEMBAHASAN

| Ketentuan | Lokasi dan bukti | Status |
| --- | --- | --- |
| Pembuatan project Flutter | 2.1: nama aplikasi TITIK SEDUH, Flutter/Dart, Flutter CLI, pengaturan kode dan izin internet | Lengkap |
| Struktur folder/berkas utama | 2.1: pohon folder memakai cabang ├──, │, └── sesuai contoh; cocok dengan berkas project | Lengkap |
| Package tambahan | 2.1: http, shared_preferences, url_launcher, perangkat pengujian/lint | Lengkap |
| Fungsi/alasan tiap package | 2.1: tabel fungsi dan alasan pemilihan; perbaikan plugin Android juga diterangkan | Lengkap |
| Rancangan UI dan fungsi halaman | 2.2: beranda, pencarian/filter, detail, favorit, navigasi dan layout responsif | Lengkap |
| Komponen utama UI | 2.2: TextField, chip, daftar/grid, kartu, NavigationBar, CustomPainter | Lengkap |
| Screenshot aplikasi/fitur | 2.2: empat screenshot Android dari UI kartun dan API sebenarnya | Lengkap |
| Nomor, judul, dan keterangan gambar | Gambar 2.1 beranda, 2.2 pencarian, 2.3 detail, 2.4 favorit; caption menjelaskan posisi kiri/kanan | Lengkap |

### Tujuh poin wajib subbab 2.3

| Poin soal | Pembahasan | Potongan kode yang relevan |
| --- | --- | --- |
| URL API dan jenis data | 2.3.1: endpoint GET /api/cafes, atribut kafe, jumlah hasil dinamis | Kode 2.1: Uri endpoint |
| Pengiriman permintaan HTTP | 2.3.2: GET, Accept JSON, await, timeout 25 detik, pemeriksaan status 200 | Kode 2.2: client.get dan statusCode |
| Struktur respons dan format | 2.3.3: contoh array JSON, atribut opsional, dekode UTF-8/JSON, validasi bentuk List/Map | Kode 2.3: jsonDecode dan pemetaan array |
| JSON menjadi objek Dart | 2.3.4: class Cafe, factory fromJson, validasi ID/nama, helper, nilai opsional | Kode 2.4: factory Cafe.fromJson |
| Asynchronous programming | 2.3.5: Future, async/await, initState, Future disimpan, muat ulang | Kode 2.5 dan 2.6; binding FutureBuilder pada Kode 2.10 |
| Penyajian pada UI | 2.3.6: snapshot.data → filter/sort → daftar kartu → properti model dalam Text | Kode 2.7, 2.8, dan 2.9 |
| Loading, berhasil, dan error | 2.3.7: connectionState, hasError, indikator, kartu berhasil, hasil kosong, retry; error di service | Kode 2.10, 2.11, dan 2.12; tabel kondisi |

Terdapat **12 cuplikan kode bernomor**, masing-masing menyebut berkas sumber dan dilengkapi penjelasan fungsi/cara kerja. Contoh JSON merupakan cuplikan respons API, bukan kode Dart. Cuplikan kode diambil dari implementasi; bagian gaya/properti tambahan yang dipotong disebutkan dalam penjelasannya. Cuplikan awal FutureBuilder memang hanya memperlihatkan awal callback; kelanjutannya dijelaskan melalui cabang UI dan daftar kartu, bukan diklaim sebagai berkas lengkap yang dapat dijalankan sendiri.

### Pengujian

Subbab 2.3.8 memuat hasil yang sudah dibuktikan: analisis kode tanpa masalah, 29 pengujian otomatis, service/model terhadap API asli, serta runtime Android API 34. Respons rusak, HTTP gagal, jaringan, timeout, filter, navigasi, favorit, ukuran layar, dan teks besar tercakup. Unit/widget test menggunakan data terkontrol; screenshot dan pemeriksaan runtime menggunakan API asli. Pengujian ponsel fisik/iOS tidak diklaim telah dilakukan. Bukti tambahan tersedia di [PENGUJIAN.md](PENGUJIAN.md).

## BAB III PENUTUP

| Ketentuan | Isi yang diperiksa | Status |
| --- | --- | --- |
| Kesimpulan hasil pengembangan | 3.1: fitur, model/HTTP, FutureBuilder, dan UI | Lengkap |
| Kesimpulan hasil pengujian | 3.1: 29 test, analisis kode, 874 rekaman saat pengujian, runtime Android | Lengkap |
| Penilaian kesesuaian tujuan | 3.1: aplikasi memenuhi tujuan penelusuran informasi kafe; batas pengujian dijelaskan | Lengkap |
| Saran pengembangan | 3.2: cache offline, sinkronisasi favorit, foto/fasilitas dari API, jadwal terstruktur, pengujian perangkat | Lengkap |

## Daftar pustaka dan format

Daftar pustaka memuat delapan sumber: dokumentasi resmi Flutter, FutureBuilder, Dart async/await, http, shared_preferences, url_launcher, changelog plugin Android, serta API. Entri disusun alfabetis berdasarkan nama lembaga dan judul, dengan judul miring, inden gantung, tautan sumber, serta tanggal akses yang konsisten. Entri referensi gambar dihapus sesuai permintaan pengguna. Laporan menggunakan bahasa Indonesia, bab/subbab sesuai soal, dan disediakan dalam DOCX serta PDF yang telah dirender untuk pemeriksaan visual. Template sumber tetap tidak diubah.

## Project dan pengumpulan akhir

| Ketentuan | Keadaan aktual |
| --- | --- |
| Flutter dan Dart, GUI minimal satu route | Tersedia beranda, favorit, dan detail; lihat lib/ |
| API dinamis, model, async, FutureBuilder | Sudah diimplementasikan; cocok dengan cuplikan laporan |
| README: nama/deskripsi/fitur/teknologi/cara menjalankan | Kelima unsur tersedia pada README.md |
| Source code lengkap dan struktur rapi | Tersedia di folder project; build dan file lokal diabaikan oleh .gitignore |
| Repositori GitHub public dan tautannya | [ikwfahmi/titik-seduh](https://github.com/ikwfahmi/titik-seduh), berstatus public; source code disertakan dalam commit project |
| Laporan PDF | **Sudah dibuat** |
| Upload PDF Google Drive, Anyone with the link, Viewer | **Akan dilakukan manual oleh pengguna sesuai instruksi** |
| Uji dua tautan tanpa login | **Dilakukan setelah unggahan manual tersedia** |

Pemeriksaan isi laporan dan project telah selesai. Pada instruksi terbaru, pengguna memberikan repositori GitHub di atas dan meminta project di-push ke sana. Unggahan PDF ke Google Drive tetap dilakukan sendiri secara manual. Setelah mengunggah PDF, pengguna perlu memastikan akses Anyone with the link sebagai Viewer, lalu menguji kedua tautan tanpa login.
