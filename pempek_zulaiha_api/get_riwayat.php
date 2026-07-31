<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "pempek_zulaiha");

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal."]);
    exit();
}

$role = $_REQUEST['role'] ?? '';
$user_id = $_REQUEST['user_id'] ?? '';

if ($role === 'admin') {
    $query = "SELECT pesanan.*, users.nama AS nama_pemesan 
              FROM pesanan 
              LEFT JOIN users ON pesanan.user_id = users.id 
              ORDER BY pesanan.id DESC";
} else {
    if (empty($user_id)) {
        echo json_encode(["success" => false, "message" => "User ID tidak boleh kosong."]);
        exit();
    }
    $query = "SELECT * FROM pesanan WHERE user_id = '$user_id' ORDER BY id DESC";
}

$result = mysqli_query($conn, $query);

if ($result) {
    $data = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $pesanan_id = $row['id'];

        // Ambil rincian barang dari tabel pesanan_detail JOIN produk
        $query_detail = "SELECT dp.*, p.nama_produk 
                         FROM pesanan_detail dp 
                         LEFT JOIN produk p ON dp.produk_id = p.id 
                         WHERE dp.pesanan_id = '$pesanan_id'";
        
        $res_detail = mysqli_query($conn, $query_detail);
        $items = [];

        if ($res_detail && mysqli_num_rows($res_detail) > 0) {
            while ($d = mysqli_fetch_assoc($res_detail)) {
                $items[] = [
                    'nama_produk'  => $d['nama_produk'] ?? 'Produk ID: ' . $d['produk_id'],
                    'jumlah'       => (int)($d['jumlah'] ?? 1),
                    'harga_satuan' => (double)($d['harga_satuan'] ?? 0),
                    'subtotal'     => (double)($d['subtotal'] ?? 0)
                ];
            }
        }
        
        $row['items'] = $items;
        $data[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $data
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal memuat riwayat."
    ]);
}
?>