# 🍡 Pempek Zulaiha - Mobile Ordering System

Aplikasi pemesanan makanan berbasis mobile untuk Toko Pempek Zulaiha. Dibangun menggunakan **Flutter** dengan manajemen state **GetX**, terintegrasi dengan backend **REST API (PHP)** dan database **MySQL**.

---

## 🚀 Fitur Utama
- **Katalog Produk:** Menampilkan pilihan menu pempek beserta harga dan deskripsi secara dinamik.
- **Keranjang & Checkout:** Perhitungan total harga otomatis dan form pengisian data pemesan beserta lokasi delivery.
- **Upload Bukti Pembayaran:** Fitur integrasi pengunggahan file/foto bukti transfer.
- **Sinkronisasi Session (User ID):** Penanganan otentikasi user berbasis `SharedPreferences` untuk menjamin integritas data pesanan.
- **Riwayat Pesanan:** Memantau status pesanan pelanggan secara real-time.
- **Notifikasi System:** Integrasi notifikasi transaksi untuk admin dan pengguna.

---

## 🛠️ Tech Stack & Dependencies
- **Frontend:** Flutter (Dart)
- **State Management & Navigation:** GetX (`get`)
- **Backend API:** Native PHP (REST API)
- **Database:** MySQL
- **Key Packages:**
  - `http`: Komunikasi REST API
  - `shared_preferences`: Manajemen sesi lokal
  - `file_picker`: Pengunggahan file bukti pembayaran

---

## ⚙️ Cara Menjalankan Project (Local Setup)

1. **Clone Repository:**
   ```bash
   git clone [https://github.com/USERNAME_KAMU/pempek-zulaiha-app.git](https://github.com/USERNAME_KAMU/pempek-zulaiha-app.git)
   cd pempek-zulaiha-app