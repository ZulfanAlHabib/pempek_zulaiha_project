<?php
// Matikan tampilan error mentah agar tidak merusak format JSON
error_reporting(0);
ini_set('display_errors', 0);

// Header CORS & JSON Output
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");

try {
    // 1. Panggil Koneksi Database
    require_once 'db_connect.php';

    $db = isset($conn) ? $conn : (isset($koneksi) ? $koneksi : null);

    if (!$db) {
        echo json_encode([
            "success" => false, 
            "message" => "Koneksi database gagal! Periksa file db_connect.php"
        ]);
        exit();
    }

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        // Ambil data POST dari Flutter
        $user_id       = $_POST['user_id'] ?? '';
        $nama_pemesan  = $_POST['nama_pemesan'] ?? '';
        $no_hp_pemesan = $_POST['no_hp_pemesan'] ?? '';
        $alamat        = $_POST['alamat'] ?? '';
        $latitude      = $_POST['latitude'] ?? '';
        $longitude     = $_POST['longitude'] ?? '';
        $total_harga   = $_POST['total_harga'] ?? 0;
        $items_raw     = $_POST['items'] ?? '[]';

        // Decode JSON item dari Flutter
        $items = json_decode($items_raw, true);

        // 2. Handling File Upload Bukti Pembayaran
        $file_path = '';
        if (isset($_FILES['bukti_pembayaran']) && $_FILES['bukti_pembayaran']['error'] == 0) {
            $target_dir = "uploads/";

            // Buat folder uploads jika belum ada di server
            if (!file_exists($target_dir)) {
                mkdir($target_dir, 0777, true);
            }

            $file_extension = pathinfo($_FILES["bukti_pembayaran"]["name"], PATHINFO_EXTENSION);
            $file_name      = time() . '_' . uniqid() . '.' . $file_extension;
            $target_file    = $target_dir . $file_name;

            if (move_uploaded_file($_FILES["bukti_pembayaran"]["tmp_name"], $target_file)) {
                $file_path = $target_file;
            }
        }

        // 3. Simpan Pesanan Utama ke Tabel `pesanan`
        $query_pesanan = "INSERT INTO pesanan (user_id, nama_pemesan, no_hp_pemesan, alamat, latitude, longitude, total_harga, bukti_pembayaran, status) 
                          VALUES ('$user_id', '$nama_pemesan', '$no_hp_pemesan', '$alamat', '$latitude', '$longitude', '$total_harga', '$file_path', 'pending')";

        if (mysqli_query($db, $query_pesanan)) {
            $pesanan_id = mysqli_insert_id($db); // Ambil ID pesanan yang baru dibuat

            // 4. Simpan Detail Produk ke Tabel `pesanan_detail` (Menggunakan kolom `harga_satuan`)
            if (is_array($items)) {
                foreach ($items as $item) {
                    $produk_id    = $item['id'] ?? $item['produk_id'] ?? 0;
                    $jumlah       = $item['jumlah'] ?? $item['qty'] ?? 1;
                    $harga_satuan = $item['harga_satuan'] ?? $item['harga'] ?? 0;

                    $query_detail = "INSERT INTO pesanan_detail (pesanan_id, produk_id, jumlah, harga_satuan) 
                                     VALUES ('$pesanan_id', '$produk_id', '$jumlah', '$harga_satuan')";
                    mysqli_query($db, $query_detail);
                }
            }

            echo json_encode([
                "success" => true,
                "message" => "Pesanan berhasil dibuat!"
            ]);

        } else {
            // Jika query gagal
            echo json_encode([
                "success" => false,
                "message" => "Gagal simpan pesanan: " . mysqli_error($db)
            ]);
        }

    } else {
        echo json_encode([
            "success" => false, 
            "message" => "Metode request harus POST"
        ]);
    }

} catch (\Throwable $e) {
    // Tangkap Fatal Error / Crash PHP agar TIDAK memicu status 500
    http_response_code(200); 
    echo json_encode([
        "success" => false, 
        "message" => "Error PHP/Database: " . $e->getMessage()
    ]);
}

if ($db) {
    $db->close();
}
?>