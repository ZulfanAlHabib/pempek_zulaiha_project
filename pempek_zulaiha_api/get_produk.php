<?php
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);
ini_set('display_errors', 0);

require_once 'db_connect.php';

$db = isset($conn) ? $conn : (isset($koneksi) ? $koneksi : null);

if (!$db) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit();
}

// Query untuk mengambil produk beserta nama kategorinya dari tabel kategori
$query = "SELECT produk.*, kategori.nama_kategori AS kategori 
          FROM produk 
          LEFT JOIN kategori ON produk.kategori_id = kategori.id 
          ORDER BY produk.id DESC";

$result = mysqli_query($db, $query);

if ($result) {
    $data = [];
    while ($row = mysqli_fetch_assoc($result)) {
        // Pastikan key 'gambar' dikirim apa adanya sesuai database
        $data[] = $row;
    }
    echo json_encode([
        "success" => true,
        "data" => $data
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal mengambil data produk"
    ]);
}
?>