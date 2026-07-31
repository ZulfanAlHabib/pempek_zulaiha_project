<?php
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0); // Matikan error HTML agar respons selalu JSON murni

require_once 'db_connect.php';

$db = isset($conn) ? $conn : (isset($koneksi) ? $koneksi : null);

if (!$db) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id       = isset($_POST['user_id']) ? $_POST['user_id'] : '1';
    $nama_pemesan  = isset($_POST['nama_pemesan']) ? $_POST['nama_pemesan'] : 'Pelanggan';
    $no_hp         = isset($_POST['no_hp_pemesan']) ? $_POST['no_hp_pemesan'] : (isset($_POST['no_hp']) ? $_POST['no_hp'] : '');
    $alamat        = isset($_POST['alamat']) ? $_POST['alamat'] : '';
    $latitude      = isset($_POST['latitude']) ? $_POST['latitude'] : '0';
    $longitude     = isset($_POST['longitude']) ? $_POST['longitude'] : '0';
    $total_harga   = isset($_POST['total_harga']) ? $_POST['total_harga'] : '0';
    $items_json    = isset($_POST['items']) ? $_POST['items'] : '[]';

    mysqli_begin_transaction($db);

    try {
        // Menggunakan created_at menyesuaikan database Anda
        $query_pesanan = "INSERT INTO pesanan (user_id, nama_pemesan, no_hp_pemesan, alamat, latitude, longitude, total_harga, status, created_at) 
                          VALUES ('$user_id', '$nama_pemesan', '$no_hp', '$alamat', '$latitude', '$longitude', '$total_harga', 'menunggu', NOW())";
        
        if (!mysqli_query($db, $query_pesanan)) {
            throw new Exception("Gagal menyimpan pesanan: " . mysqli_error($db));
        }

        $pesanan_id = mysqli_insert_id($db);
        $items = json_decode($items_json, true);

        if (!empty($items) && is_array($items)) {
            foreach ($items as $item) {
                $produk_id    = isset($item['produk_id']) ? $item['produk_id'] : (isset($item['id']) ? $item['id'] : 0);
                $jumlah       = isset($item['jumlah']) ? $item['jumlah'] : 0;
                $harga_satuan = isset($item['harga_satuan']) ? $item['harga_satuan'] : 0;
                $subtotal     = isset($item['subtotal']) ? $item['subtotal'] : 0;

                $query_detail = "INSERT INTO pesanan_detail (pesanan_id, produk_id, jumlah, harga_satuan, subtotal) 
                                 VALUES ('$pesanan_id', '$produk_id', '$jumlah', '$harga_satuan', '$subtotal')";
                
                if (!mysqli_query($db, $query_detail)) {
                    throw new Exception("Gagal menyimpan detail pesanan: " . mysqli_error($db));
                }

                // Update stok
                $query_update_stok = "UPDATE produk SET stok = stok - $jumlah WHERE id = '$produk_id'";
                mysqli_query($db, $query_update_stok);
            }
        }

        mysqli_commit($db);
        echo json_encode([
            "success" => true,
            "message" => "Pesanan berhasil dibuat"
        ]);

    } catch (Exception $e) {
        mysqli_rollback($db);
        echo json_encode([
            "success" => false,
            "message" => $e->getMessage()
        ]);
    }

} else {
    echo json_encode([
        "success" => false,
        "message" => "Metode request tidak valid"
    ]);
}
?>