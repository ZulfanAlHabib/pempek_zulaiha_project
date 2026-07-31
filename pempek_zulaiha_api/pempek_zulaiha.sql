-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 31 Jul 2026 pada 18.01
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pempek_zulaiha`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `kategori`
--

CREATE TABLE `kategori` (
  `id` int(11) NOT NULL,
  `nama_kategori` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kategori`
--

INSERT INTO `kategori` (`id`, `nama_kategori`) VALUES
(1, 'Pempek'),
(2, 'Cuko & Pelengkap'),
(3, 'Minuman');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id_notifikasi` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL COMMENT 'Isi dengan ID User jika notifikasi khusus untuk 1 orang, biarkan NULL jika untuk role/global',
  `role_target` enum('all','admin','pelanggan','guest') DEFAULT 'all' COMMENT 'Target penerima notifikasi',
  `judul` varchar(100) NOT NULL,
  `pesan` text NOT NULL,
  `tipe` varchar(50) DEFAULT 'info' COMMENT 'Contoh: info, promo, pesanan, peringatan (berguna untuk icon di Flutter)',
  `is_read` tinyint(1) DEFAULT 0 COMMENT '0 = Belum dibaca, 1 = Sudah dibaca',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `notifikasi`
--

INSERT INTO `notifikasi` (`id_notifikasi`, `id_user`, `role_target`, `judul`, `pesan`, `tipe`, `is_read`, `created_at`) VALUES
(1, NULL, 'guest', 'Selamat Datang di Pempek Zulaiha!', 'Silakan Login terlebih dahulu untuk dapat melakukan checkout pesanan.', 'info', 0, '2026-07-31 08:40:37'),
(2, NULL, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari pelanggan yang perlu diperiksa.', 'pesanan', 0, '2026-07-31 08:40:37'),
(3, NULL, 'pelanggan', 'Promo Spesial Pempek Zulaiha!', 'Dapatkan penawaran harga hemat untuk pembelian Paket Kapal Selam!', 'promo', 0, '2026-07-31 08:40:37'),
(4, NULL, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #13. Segera periksa daftar pesanan.', 'pesanan', 0, '2026-07-31 14:36:26'),
(5, NULL, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #14. Segera periksa daftar pesanan.', 'pesanan', 0, '2026-07-31 14:44:29'),
(6, NULL, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #15. Segera periksa daftar pesanan.', 'pesanan', 0, '2026-07-31 14:46:27'),
(7, NULL, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #16. Segera periksa daftar pesanan.', 'pesanan', 0, '2026-07-31 14:57:38'),
(8, NULL, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #17. Segera periksa daftar pesanan.', 'pesanan', 0, '2026-07-31 15:13:23'),
(9, 0, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #27.', 'pesanan', 0, '2026-07-31 15:26:29'),
(10, 0, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #28.', 'pesanan', 0, '2026-07-31 15:33:41'),
(11, 0, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #29.', 'pesanan', 0, '2026-07-31 15:42:18'),
(12, 0, 'admin', 'Pesanan Baru Masuk!', 'Ada pesanan baru dari user dengan ID Pesanan #30.', 'pesanan', 0, '2026-07-31 15:44:38');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pesanan`
--

CREATE TABLE `pesanan` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `nama_pemesan` varchar(100) NOT NULL,
  `no_hp_pemesan` varchar(20) NOT NULL,
  `alamat` text NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `total_harga` decimal(10,2) NOT NULL,
  `bukti_pembayaran` varchar(255) DEFAULT NULL,
  `status` enum('menunggu','diproses','dikirim','selesai','dibatalkan') DEFAULT 'menunggu',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pesanan`
--

INSERT INTO `pesanan` (`id`, `user_id`, `nama_pemesan`, `no_hp_pemesan`, `alamat`, `latitude`, `longitude`, `total_harga`, `bukti_pembayaran`, `status`, `created_at`) VALUES
(2, NULL, 'Pelanggan', '0895605919551', 'jl. letnan sucipto', -6.1290207, 106.9000908, 370000.00, NULL, 'selesai', '2026-07-26 12:12:28'),
(5, 2, 'Pelanggan', '0888', '0', -6.2522877, 106.9328945, 38000.00, NULL, 'menunggu', '2026-07-29 08:55:33'),
(6, 2, 'Pelanggan', '08', '0', -6.2523189, 106.9327570, 6000.00, NULL, 'menunggu', '2026-07-29 08:56:26'),
(7, 2, 'Pelanggan', '089', 'Jl. Raya Kalimalang No.89, Pondok Kelapa, Kecamatan Duren Sawit, Kota Jakarta Timur', -6.2522996, 106.9328855, 6000.00, NULL, 'menunggu', '2026-07-29 09:08:59'),
(8, 2, 'user', '0812', 'Jl. Raya Kalimalang No.89, Pondok Kelapa, Kecamatan Duren Sawit, Kota Jakarta Timur', -6.2523300, 106.9328751, 18000.00, NULL, 'menunggu', '2026-07-29 09:21:02'),
(9, 1, 'coon', '055', 'Jl. Raya Kalimalang No.89, Pondok Kelapa, Kecamatan Duren Sawit, Kota Jakarta Timur', -6.2522904, 106.9329125, 8000.00, NULL, 'selesai', '2026-07-29 09:25:37'),
(10, 2, 'user', '000', 'Jl. Raya Kalimalang No.89, Pondok Kelapa, Kecamatan Duren Sawit, Kota Jakarta Timur', -6.2522894, 106.9328848, 18000.00, NULL, 'dibatalkan', '2026-07-30 08:00:51'),
(12, 2, 'user', '1323', 'Jl. Raya Kalimalang No.89, Pondok Kelapa, Kecamatan Duren Sawit, Kota Jakarta Timur', -6.2522866, 106.9328634, 100000.00, 'bukti_1785401382_2248.jpg', 'diproses', '2026-07-30 08:49:42'),
(13, 1, 'user', '08888', 'Jl. Air Laut 1 No.71, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290185, 106.9000786, 180000.00, 'bukti_1785508586_6041.jpeg', 'menunggu', '2026-07-31 14:36:26'),
(14, 1, 'user', '8580', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290684, 106.9000742, 50000.00, 'bukti_1785509069_6065.jpg', 'dikirim', '2026-07-31 14:44:29'),
(15, 1, 'user', '86068', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290720, 106.9000732, 80000.00, 'bukti_1785509187_8240.jpeg', 'menunggu', '2026-07-31 14:46:27'),
(16, 1, 'user', '7777', 'Jl. Air Laut 1 No.71, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290378, 106.9000796, 120000.00, 'bukti_1785509858_3374.jpg', 'menunggu', '2026-07-31 14:57:38'),
(17, 1, 'user', '12355', 'Jl. Air Laut 1 No.71, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290477, 106.9000796, 300000.00, 'bukti_1785510803_2362.jpeg', 'menunggu', '2026-07-31 15:13:23'),
(18, 1, 'user', '0888888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290616, 106.9000742, 300000.00, 'bukti_1785511138_6285.jpeg', 'menunggu', '2026-07-31 15:18:58'),
(19, 1, 'user', '0888888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290616, 106.9000742, 300000.00, 'bukti_1785511149_3373.jpeg', 'menunggu', '2026-07-31 15:19:09'),
(20, 1, 'user', '0888888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290616, 106.9000742, 300000.00, 'bukti_1785511165_6395.jpeg', 'menunggu', '2026-07-31 15:19:25'),
(21, 1, 'user', '0888888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290616, 106.9000742, 300000.00, 'bukti_1785511194_5317.jpeg', 'menunggu', '2026-07-31 15:19:54'),
(22, 1, 'user', '0888888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290616, 106.9000742, 300000.00, 'bukti_1785511206_8192.jpeg', 'menunggu', '2026-07-31 15:20:06'),
(23, 1, 'user', '0888888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290616, 106.9000742, 300000.00, 'bukti_1785511215_4870.jpeg', 'menunggu', '2026-07-31 15:20:15'),
(24, 1, 'user', '0888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290878, 106.9000737, 300000.00, 'bukti_1785511503_3920.jpeg', 'menunggu', '2026-07-31 15:25:03'),
(25, 1, 'user', '0888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290878, 106.9000737, 300000.00, 'bukti_1785511506_2827.jpeg', 'menunggu', '2026-07-31 15:25:06'),
(26, 1, 'user', '0888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290878, 106.9000737, 300000.00, 'bukti_1785511507_2593.jpeg', 'menunggu', '2026-07-31 15:25:07'),
(27, 1, 'user', '0888', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290878, 106.9000737, 300000.00, 'bukti_1785511589_7548.jpeg', 'menunggu', '2026-07-31 15:26:29'),
(28, 1, 'user', '11111', 'Jl. Air Laut 1 No.71, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290357, 106.9000810, 300000.00, 'bukti_1785512021_9274.jpeg', 'menunggu', '2026-07-31 15:33:41'),
(29, 1, 'user', '00000', 'Jl. Air Laut 1 No.71, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290385, 106.9000844, 200000.00, 'bukti_1785512538_5762.jpeg', 'menunggu', '2026-07-31 15:42:18'),
(30, 2, 'user', '0000', 'Jl. Air Laut 1 No.82, Rawabadak Selatan, Kecamatan Koja, Jakarta Utara', -6.1290554, 106.9000775, 50000.00, 'bukti_1785512678_2435.jpeg', 'dikirim', '2026-07-31 15:44:38');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pesanan_detail`
--

CREATE TABLE `pesanan_detail` (
  `id` int(11) NOT NULL,
  `pesanan_id` int(11) NOT NULL,
  `produk_id` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `harga_satuan` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pesanan_detail`
--

INSERT INTO `pesanan_detail` (`id`, `pesanan_id`, `produk_id`, `jumlah`, `harga_satuan`, `subtotal`) VALUES
(5, 5, 18, 1, 6000.00, 6000.00),
(6, 5, 14, 1, 8000.00, 8000.00),
(7, 5, 13, 1, 12000.00, 12000.00),
(8, 5, 12, 1, 12000.00, 12000.00),
(9, 6, 18, 1, 6000.00, 6000.00),
(10, 7, 18, 1, 6000.00, 6000.00),
(11, 8, 18, 3, 6000.00, 18000.00),
(12, 9, 14, 1, 8000.00, 8000.00),
(13, 10, 10, 1, 5000.00, 5000.00),
(14, 10, 6, 1, 4000.00, 4000.00),
(15, 10, 3, 1, 4000.00, 4000.00),
(16, 10, 2, 1, 5000.00, 5000.00),
(17, 12, 10, 2, 5000.00, 10000.00),
(18, 13, 10, 1, 5000.00, 5000.00),
(19, 13, 6, 1, 4000.00, 4000.00),
(20, 13, 2, 1, 5000.00, 5000.00),
(21, 13, 3, 1, 4000.00, 4000.00),
(22, 14, 10, 1, 5000.00, 5000.00),
(23, 15, 6, 2, 4000.00, 8000.00),
(24, 16, 3, 3, 4000.00, 12000.00),
(25, 17, 10, 6, 5000.00, 30000.00),
(26, 18, 10, 6, 5000.00, 30000.00),
(27, 19, 10, 6, 5000.00, 30000.00),
(28, 20, 10, 6, 5000.00, 30000.00),
(29, 21, 10, 6, 5000.00, 30000.00),
(30, 22, 10, 6, 5000.00, 30000.00),
(31, 23, 10, 6, 5000.00, 30000.00),
(32, 24, 10, 6, 5000.00, 30000.00),
(33, 25, 10, 6, 5000.00, 30000.00),
(34, 26, 10, 6, 5000.00, 30000.00),
(35, 27, 10, 6, 5000.00, 30000.00),
(36, 28, 10, 6, 5000.00, 30000.00),
(37, 29, 10, 4, 5000.00, 20000.00),
(38, 30, 10, 1, 5000.00, 5000.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `produk`
--

CREATE TABLE `produk` (
  `id` int(11) NOT NULL,
  `kategori_id` int(11) DEFAULT NULL,
  `nama_produk` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `harga` decimal(10,2) NOT NULL,
  `stok` int(11) DEFAULT 0,
  `gambar` varchar(255) DEFAULT NULL,
  `is_aktif` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `produk`
--

INSERT INTO `produk` (`id`, `kategori_id`, `nama_produk`, `deskripsi`, `harga`, `stok`, `gambar`, `is_aktif`, `created_at`) VALUES
(1, 1, 'Pempek Kapal Selam', 'Pempek isi telur ukuran besar', 8000.00, 50, '1785311323_1000736981.jpg', 1, '2026-07-25 14:56:28'),
(2, 1, 'Pempek Lenjer', 'Pempek panjang khas Palembang', 5000.00, 99, 'lenjer.jpg', 1, '2026-07-25 14:56:28'),
(3, 1, 'Pempek Adaan', 'Pempek bulat digoreng', 4000.00, 79, 'adaan.jpeg', 1, '2026-07-25 14:56:28'),
(4, 1, 'Pempek Keriting', 'Pempek bentuk keriting', 5000.00, 60, 'keriting.jpg', 1, '2026-07-25 14:56:28'),
(5, 2, 'Cuko Extra Pedas', 'Cuko tambahan botol 250ml', 5000.00, 40, 'cuko.jpg', 1, '2026-07-25 14:56:28'),
(6, 3, 'Es Teh Manis', 'Minuman pelengkap', 4000.00, 99, 'es_teh.jpg', 1, '2026-07-25 14:56:28'),
(7, 1, 'Pempek Komplit', 'Paket komplit yang berisi berbagai jenis Pempek, yaitu :Kapal Selam, Lenjer, Adaan, Keriting', 20000.00, 25, '1785308182_1000734547.jpg', 1, '2026-07-29 06:56:22'),
(8, 1, 'Pempek Tunu/Panggang', 'Pempek yang dibakar diatas bara api lalu dibelah dan diberi isi ebi, kecap, serta cabai', 8000.00, 35, '1785310239_1000736969.jpg', 1, '2026-07-29 07:30:39'),
(9, 1, 'Pempek Lenggang ', 'Adonan pempek dicampur telur kocok laly dipanggang atau digoreng diatas daun pisang atau bara api. ', 6000.00, 35, '1785310316_1000736966.jpg', 1, '2026-07-29 07:31:56'),
(10, 1, 'Pempek Kulit', 'Dibuat dengan campuran kulit ikan sehingga aroma dan rasa. gurihnya lebih kuat', 5000.00, 4999, '1785310366_1000736965.jpg', 1, '2026-07-29 07:32:46'),
(11, 3, 'Aqua', 'Air putih 600 ml', 5000.00, 24, '1785311730_1000736988.jpg', 1, '2026-07-29 07:55:30'),
(12, 1, 'Lakso', 'Hidangan mie gurih yang disajikan dalam kuah berbahan santan kelapa berwarna kekuningan yang gurih, dan ditaburi bawang goreng. ', 12000.00, 20, '1785311916_1000736993.jpg', 1, '2026-07-29 07:58:36'),
(13, 1, 'Burgo', 'Makanan yang. disajikan dengan cara dipotong potong lalu disiram kuah santan gurih berbahan ikan gabus atau ebi. ', 12000.00, 20, '1785312016_1000736989.jpg', 1, '2026-07-29 08:00:16'),
(14, 3, 'Es Kacang Merah ', 'Es khas Palembang yang terbuat dari kacang merah ', 8000.00, 19, '1785312070_1000736990.jpg', 1, '2026-07-29 08:01:10'),
(15, 1, 'Pistel', 'Makanan khas Palembang yang bertekstur lembut berisi pepaya muda parut berbumbu. ', 5000.00, 35, '1785312177_1000736991.jpg', 1, '2026-07-29 08:02:57'),
(16, 1, 'Tekwan', 'Makanan khas Palembang yang berkuah udang dengan rasa khas. ', 12000.00, 0, '1785312273_1000736992.jpg', 1, '2026-07-29 08:04:33'),
(17, 2, 'Sambel Cuko Tambahan', 'Sachet kecil berisi ulekan cabai rawit kecil murni untuk cuko kurang pedas. ', 5000.00, 40, '1785313015_1000736996.jpg', 1, '2026-07-29 08:16:55'),
(18, 3, 'Es Jeruk Kunci', 'Perasan jeruk kasturi atau kunci yang sangat segar, dan asam', 6000.00, 36, '1785313100_1000736995.jpg', 1, '2026-07-29 08:18:20'),
(19, 2, 'Ebi Bubuk ', 'Udang kering sangrai halus yang dikemas dalam botol kecil. ', 5000.00, 40, '1785313228_1000736994.jpg', 1, '2026-07-29 08:20:28');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `role` varchar(20) DEFAULT 'pelanggan'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `no_hp`, `created_at`, `role`) VALUES
(1, 'admin1', 'zulfanalhabib@gmail.com', '$2y$10$O3jWpHuM0PoF0WEINoIScuhZE/mBTSIYYcUF4ASJK2wzwESPB3DvG', '08956405919551', '2026-07-26 04:36:14', 'admin'),
(2, 'user', 'alhabibzulfan@gmail.com', '$2y$10$O9w6m6FTxVpTHpqDm2l9S.wej6dU7Zw5t031UC86qWuYiwWTk2C6W', '08123456789', '2026-07-29 03:33:36', 'pelanggan');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id_notifikasi`);

--
-- Indeks untuk tabel `pesanan`
--
ALTER TABLE `pesanan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `pesanan_detail`
--
ALTER TABLE `pesanan_detail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pesanan_id` (`pesanan_id`),
  ADD KEY `produk_id` (`produk_id`);

--
-- Indeks untuk tabel `produk`
--
ALTER TABLE `produk`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kategori_id` (`kategori_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id_notifikasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `pesanan`
--
ALTER TABLE `pesanan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT untuk tabel `pesanan_detail`
--
ALTER TABLE `pesanan_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT untuk tabel `produk`
--
ALTER TABLE `produk`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `pesanan`
--
ALTER TABLE `pesanan`
  ADD CONSTRAINT `pesanan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `pesanan_detail`
--
ALTER TABLE `pesanan_detail`
  ADD CONSTRAINT `pesanan_detail_ibfk_1` FOREIGN KEY (`pesanan_id`) REFERENCES `pesanan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pesanan_detail_ibfk_2` FOREIGN KEY (`produk_id`) REFERENCES `produk` (`id`);

--
-- Ketidakleluasaan untuk tabel `produk`
--
ALTER TABLE `produk`
  ADD CONSTRAINT `produk_ibfk_1` FOREIGN KEY (`kategori_id`) REFERENCES `kategori` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
