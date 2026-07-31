<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$koneksi = new mysqli("localhost", "root", "", "pempek_zulaiha");

if ($koneksi->connect_error) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal."]);
    exit();
}

// Tangkap data dari Flutter
$user_id       = $_POST['user_id'] ?? null;
$nama_pemesan  = $_POST['nama_pemesan'] ?? 'Pelanggan';
$no_hp_pemesan = $_POST['no_hp_pemesan'] ?? '-';
$alamat        = $_POST['alamat'] ?? '-';
$latitude      = $_POST['latitude'] ?? null;
$longitude     = $_POST['longitude'] ?? null;
$items_json    = $_POST['items'] ?? '[]'; // Data JSON rincian barang

// Validasi User ID
if (empty($user_id) || $user_id === 'null' || $user_id == 0) {
    echo json_encode(["success" => false, "message" => "Gagal: Sesi pengguna tidak valid. Silakan Login ulang."]);
    exit();
}

// Tangkap total harga (Ambil angka saja)
$harga_kotor = $_POST['total_harga'] ?? '0';
$total_harga = preg_replace('/[^0-9]/', '', $harga_kotor); 

if ($latitude == '' || $latitude == 'Belum didapatkan') $latitude = '0.0000000';
if ($longitude == '' || $longitude == 'Belum didapatkan') $longitude = '0.0000000';

// Upload Bukti Pembayaran
$nama_file_bukti = "";
if (isset($_FILES['bukti_pembayaran']) && $_FILES['bukti_pembayaran']['error'] == 0) {
    $target_dir = "uploads/";
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }

    $ext = pathinfo($_FILES['bukti_pembayaran']['name'], PATHINFO_EXTENSION);
    $nama_file_bukti = "bukti_" . time() . "_" . rand(1000, 9999) . "." . $ext;
    $target_file = $target_dir . $nama_file_bukti;

    if (!move_uploaded_file($_FILES['bukti_pembayaran']['tmp_name'], $target_file)) {
        echo json_encode(["success" => false, "message" => "Gagal mengunggah berkas bukti pembayaran."]);
        exit();
    }
}

// 1. Simpan ke tabel pesanan
$sql = "INSERT INTO pesanan (user_id, nama_pemesan, no_hp_pemesan, alamat, latitude, longitude, total_harga, bukti_pembayaran, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'menunggu')";

$stmt = $koneksi->prepare($sql);
$stmt->bind_param("isssssds", $user_id, $nama_pemesan, $no_hp_pemesan, $alamat, $latitude, $longitude, $total_harga, $nama_file_bukti);

if ($stmt->execute()) {
    $pesanan_id = $stmt->insert_id; 
    $stmt->close();

    // 2. Decode JSON items dari Flutter & Simpan ke pesanan_detail
    $items = json_decode($items_json, true);

    if (is_array($items) && !empty($items)) {
        foreach ($items as $item) {
            $produk_id    = $item['id'] ?? $item['produk_id'] ?? 0;
            $jumlah       = $item['jumlah'] ?? 1;
            $harga_satuan = $item['harga_satuan'] ?? 0;
            $subtotal     = $item['subtotal'] ?? 0;

            $sql_detail = "INSERT INTO pesanan_detail (pesanan_id, produk_id, jumlah, harga_satuan, subtotal) 
                           VALUES (?, ?, ?, ?, ?)";
            $stmt_detail = $koneksi->prepare($sql_detail);
            $stmt_detail->bind_param("iiidd", $pesanan_id, $produk_id, $jumlah, $harga_satuan, $subtotal);
            $stmt_detail->execute();
            $stmt_detail->close();
        }
    }

    // 3. TRIGGER NOTIFIKASI (Menggunakan kolom 'tipe' sesuai database kamu)
    $judul_notif = "Pesanan Baru Masuk!";
    $pesan_notif = "Ada pesanan baru dari " . $nama_pemesan . " dengan ID Pesanan #" . $pesanan_id . ".";
    $role_target = "admin";
    $tipe        = "pesanan"; // Kolom di database bernama 'tipe'

    $sql_notif = "INSERT INTO notifikasi (id_user, role_target, judul, pesan, tipe, created_at) 
                  VALUES (0, ?, ?, ?, ?, NOW())";
    
    $stmt_notif = $koneksi->prepare($sql_notif);
    $stmt_notif->bind_param("ssss", $role_target, $judul_notif, $pesan_notif, $tipe);
    $stmt_notif->execute();
    $stmt_notif->close();

    echo json_encode(["success" => true, "message" => "Pesanan berhasil disimpan."]);
} else {
    echo json_encode(["success" => false, "message" => "Error database: " . $koneksi->error]);
}

$koneksi->close();
?>