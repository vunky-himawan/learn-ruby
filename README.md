# Proyek Ruby on Rails: Sistem Informasi Perpustakaan dengan Fitur Realtime

Berikut adalah panduan untuk proyek sistem informasi perpustakaan yang telah diperbarui untuk menyertakan fitur realtime menggunakan WebSocket, selain caching, throttling, job dan queue, email, dan API. Proyek ini dirancang untuk membantu Anda belajar Ruby on Rails sambil mengintegrasikan teknologi modern dan praktik backend engineering, termasuk pengujian yang relevan.

## Gambaran Proyek

Sistem informasi perpustakaan memungkinkan pengguna untuk mengelola buku, meminjam dan mengembalikan buku, melihat riwayat peminjaman, serta menerima pembaruan secara realtime (misalnya, notifikasi stok buku atau peminjaman baru). Proyek ini mencakup:

- Autentikasi pengguna dengan peran admin dan anggota.
- Manajemen buku dan peminjaman.
- Notifikasi email untuk konfirmasi peminjaman/pengembalian.
- API untuk operasi CRUD.
- Throttling untuk membatasi penggunaan API.
- Caching untuk performa.
- Background job dan queue untuk pemrosesan asinkronus.
- WebSocket untuk pembaruan realtime seperti notifikasi stok atau aktivitas peminjaman.
- Pengujian komprehensif untuk semua komponen.

## Fitur Utama

1. Autentikasi Pengguna

   - Gunakan Devise untuk registrasi, login, dan manajemen sesi pengguna.
   - Bedakan peran: admin (mengelola buku dan peminjaman) dan anggota (meminjam buku).
   - Terapkan otorisasi menggunakan Pundit atau CanCanCan untuk mengontrol akses berdasarkan peran.

2. Manajemen Buku

   - Admin dapat menambah, mengedit, dan menghapus buku (judul, penulis, ISBN, jumlah stok).
   - Simpan data di database dengan validasi (misalnya, ISBN unik, stok tidak negatif).
   - Anggota dapat mencari dan melihat detail buku.

3. Peminjaman dan Pengembalian

   - Anggota dapat meminjam buku jika stok tersedia, dengan batas tenggat pengembalian.
   - Sistem mencatat tanggal peminjaman, tenggat, dan status pengembalian.
   - Admin dapat memproses pengembalian dan memperbarui stok.

4. Fitur Realtime dengan WebSocket

   - Gunakan Action Cable (fitur bawaan Rails untuk WebSocket) untuk:
   - Memberi notifikasi realtime kepada admin saat stok buku berubah (misalnya, saat buku dipinjam atau dikembalikan).
   - Menampilkan pembaruan langsung di dashboard anggota tentang status peminjaman mereka.
   - Mengirim notifikasi ke anggota saat buku yang mereka cari kembali tersedia.
   - Contoh: Ketika buku dikembalikan, semua admin yang sedang melihat dashboard menerima pembaruan stok secara langsung.

5. Caching

   - Gunakan Redis atau Memcached untuk menyimpan cache daftar buku populer, hasil pencarian, atau data dashboard.
   - Cache data yang sering diakses untuk mengurangi beban database.

6. Throttling

   - Terapkan rate limiting pada endpoint API menggunakan rack-attack.
   - Contoh: Batasi 100 permintaan per menit untuk anggota, 500 untuk admin.

7. Background Job dan Queue

   - Gunakan Active Job dengan Sidekiq (didukung Redis) untuk:
   - Mencatat log peminjaman secara asinkronus.
   - Memproses notifikasi email untuk peminjaman dan pengembalian.
   - Pastikan job di-queue untuk menghindari penundaan pada antarmuka pengguna.

8. Notifikasi Email

   - Kirim email konfirmasi ke anggota saat peminjaman atau pengembalian berhasil menggunakan Action Mailer.
   - Integrasikan dengan layanan seperti SendGrid atau Postmark untuk pengiriman email yang andal.

9. API

   - Sediakan endpoint RESTful untuk:
     - Manajemen buku (POST /api/v1/books, GET /api/v1/books/:id, dll.).
     - Manajemen peminjaman (POST /api/v1/loans, GET /api/v1/loans/:id).
   - Gunakan autentikasi berbasis token API atau JWT untuk mengamankan endpoint.
   - Kembalikan respons dalam format JSON dengan status kode yang sesuai.

10. Dashboard Pengguna

    - Tampilkan riwayat peminjaman dan status buku untuk anggota.
    - Admin dapat melihat laporan seperti buku paling sering dipinjam atau daftar peminjaman aktif.
    - Gunakan chartkick untuk visualisasi data sederhana (misalnya, grafik peminjaman per bulan).
    - Integrasikan pembaruan realtime menggunakan Action Cable untuk menampilkan perubahan stok atau status peminjaman.

## Konsep Tambahan untuk Dipelajari

1. **Indeks Database**: Tambahkan indeks pada kolom seperti ISBN, user_id, atau loan_status untuk mempercepat query.

2. **Optimasi WebSocket**:

   - Batasi langganan channel Action Cable untuk menghindari overhead (misalnya, hanya pengguna aktif yang menerima pembaruan).
   - Gunakan Redis untuk menyimpan state WebSocket di lingkungan produksi.

3. **Penanganan Error**:

   - Tangani error seperti stok tidak cukup, input tidak valid, atau kegagalan WebSocket.
   - Berikan pesan error yang jelas di API dan antarmuka web.

4. **Logging**: Catat aktivitas seperti peminjaman, error API, atau kegagalan WebSocket menggunakan logging Rails.

5. **Paginasi**: Terapkan paginasi pada daftar buku dan riwayat peminjaman dengan will_paginate atau kaminari.

6. **Keamanan**:

   - Validasi input untuk mencegah SQL injection atau XSS.
   - Amankan WebSocket dengan autentikasi untuk memastikan hanya pengguna yang berwenang menerima pembaruan.
   - Gunakan HTTPS untuk API dan WebSocket.

7. **Optimasi Kueri**: Gunakan includes atau joins untuk menghindari N+1 query pada relasi seperti buku dan peminjaman.

8. **Versi API**: Strukturkan API dengan versioning (misalnya, /api/v1/) untuk mendukung pembaruan di masa depan.

## Jenis Pengujian untuk Dipelajari

Untuk menjadi backend engineer yang kompeten, pelajari dan terapkan pengujian berikut:

1. Unit Testing:

   - Uji validasi model (misalnya, ISBN unik, stok tidak negatif) menggunakan RSpec atau Minitest.
   - Uji logika kustom seperti perhitungan tenggat peminjaman atau pembuatan short code.

2. Integration Testing:

   - Uji alur lengkap seperti peminjaman buku, pengembalian, dan pembaruan stok.
   - Uji endpoint API untuk memastikan respons dan penanganan error yang benar.

3. Controller Testing:

   - Uji aksi controller untuk web dan API, termasuk autentikasi, otorisasi, dan throttling.

4. WebSocket Testing:

   - Uji channel Action Cable menggunakan rspec-actioncable atau alat serupa untuk memastikan pembaruan realtime dikirim dengan benar.
   - Uji skenario seperti koneksi terputus atau autentikasi gagal.

5. Job Testing:

   - Uji background job (misalnya, log peminjaman, pengiriman email) dengan rspec-sidekiq.
   - Pastikan job di-queue dan diproses dengan benar.

6. System Testing:

   - Uji alur pengguna (misalnya, mendaftar, meminjam buku, menerima notifikasi realtime) dengan Capybara untuk simulasi browser.

7. Performance Testing:

   - Gunakan rack-mini-profiler untuk mengidentifikasi bottleneck pada caching, query, atau WebSocket.
   - Uji skalabilitas WebSocket dengan banyak koneksi bersamaan.

8. API Testing:

   - Gunakan Postman atau httparty untuk menguji endpoint API.
   - Uji rate limiting dengan skenario permintaan berulang.

## Alat dan Gem yang Direkomendasikan

1. **Devise**: Untuk autentikasi pengguna.
2. **Pundit** atau **CanCanCan**: Untuk otorisasi berdasarkan peran.
3. **Action Cable**: Untuk fitur realtime berbasis WebSocket.
4. **Sidekiq**: Untuk background job dengan Redis.
5. **Rack-attack**: Untuk throttling API.
6. **Action Mailer**: Untuk pengiriman email.
7. **Redis**: Untuk caching, queue, dan state WebSocket.
8. **Will_paginate** atau **Kaminari**: Untuk paginasi.
9. **Rspec-rails**: Untuk pengujian (lebih fleksibel dibandingkan Minitest).
10. **FactoryBot**: Untuk membuat data uji.
11. **Capybara**: Untuk system testing.
12. **Shoulda-matchers**: Untuk menyederhanakan pengujian model.
13. **rspec-actioncable**: Untuk menguji WebSocket (opsional, tergantung kompleksitas).

## Hasil Pembelajaran

Dengan membangun proyek ini, Anda akan mempelajari:

1. Cara merancang aplikasi Rails dengan arsitektur MVC dan prinsip RESTful.
2. Cara mengelola relasi database (user-books-loans).
3. Cara mengimplementasikan fitur realtime dengan WebSocket menggunakan Action Cable.
4. Cara mengoptimalkan performa dengan caching dan kueri efisien.
5. Cara memproses tugas asinkronus dengan job dan queue.
6. Cara membangun dan mengamankan API.
7. Cara mengirim email di lingkungan produksi.
8. Cara menulis pengujian komprehensif untuk aplikasi backend, termasuk WebSocket.
9. Cara menangani tantangan backend seperti keamanan, logging, dan skalabilitas.

## Langkah Berikutnya

1. Buat proyek Rails baru dengan database PostgreSQL.
2. Pasang dan konfigurasikan gem yang diperlukan (Devise, Action Cable, Sidekiq, dll.).
3. Rancang skema database untuk buku, peminjaman, dan pengguna.
4. Implementasikan fitur inti: manajemen buku, peminjaman, dan dashboard.
5. Tambahkan fitur realtime dengan Action Cable untuk notifikasi stok dan peminjaman.
6. Terapkan caching dan throttling.
7. Siapkan background job dan notifikasi email.
8. Bangun dan amankan API dengan autentikasi.
9. Tulis pengujian untuk semua komponen, termasuk WebSocket.
10. Deploy ke platform seperti Heroku atau Render, pastikan Redis diatur untuk produksi.

Proyek ini memberikan pengalaman praktis dalam membangun sistem informasi perpustakaan dengan fitur modern seperti realtime update, sekaligus memperkuat keterampilan backend engineering Anda.
