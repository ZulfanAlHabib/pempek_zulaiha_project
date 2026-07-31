<?php
header("Content-Type: application/json; charset=UTF-8");
ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once 'db_connect.php';

$db = isset($conn) ? $conn : (isset($koneksi) ? $koneksi : null);

if (!$db) {
    echo json_encode(["success" => false, "message" => "Variabel koneksi database tidak ditemukan!"]);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id             = isset($_POST['id']) ? $_POST['id'] : '';
    $nama           = isset($_POST['nama_produk']) ? $_POST['nama_produk'] : '';
    $harga          = isset($_POST['harga']) ? $_POST['harga'] : '';
    $deskripsi      = isset($_POST['deskripsi']) ? $_POST['deskripsi'] : '-';
    $stok           = isset($_POST['stok']) ? (int)$_POST['stok'] : 0;
    $kategori_input = isset($_POST['kategori']) ? $_POST['kategori'] : 'Makanan';

    if (empty($id) || empty($nama) || empty($harga)) {
        echo json_encode(["success" => false, "message" => "Data ID, Nama, dan Harga wajib diisi"]);
        exit();
    }

    // Konversi Kategori ke ID
    $kategori_id = 1;
    $q_kategori = mysqli_query($db, "SELECT id FROM kategori WHERE nama_kategori = '$kategori_input' LIMIT 1");
    if ($q_kategori && $row = mysqli_fetch_assoc($q_kategori)) {
        $kategori_id = $row['id'];
    }

    // Cek apakah ada file gambar baru yang diunggah
    $update_gambar_query = "";
    if (isset($_FILES['gambar']['name']) && $_FILES['gambar']['name'] != '') {
        $nama_file = time() . '_' . basename($_FILES['gambar']['name']);
        $target_dir = "images/";
        $target_file = $target_dir . $nama_file;
        
        if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
            $update_gambar_query = ", gambar = '$nama_file'";
        }
    }

    // Query Update lengkap
    $query = "UPDATE produk SET 
              kategori_id = '$kategori_id', 
              nama_produk = '$nama', 
              deskripsi = '$deskripsi', 
              harga = '$harga', 
              stok = '$stok' 
              $update_gambar_query 
              WHERE id = '$id'";

    try {
        if (mysqli_query($db, $query)) {
            echo json_encode(["success" => true, "message" => "Produk berhasil diperbarui!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal UPDATE: " . mysqli_error($db)]);
        }
    } catch (Exception $e) {
        echo json_encode(["success" => false, "message" => "Error Query: " . $e->getMessage()]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Bukan metode POST"]);
}
?>