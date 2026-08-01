<?php
// Matikan penampakan error langsung ke output agar format JSON tetap murni
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");

try {
    require_once 'db_connect.php';

    $db = isset($conn) ? $conn : (isset($koneksi) ? $koneksi : null);

    if (!$db) {
        echo json_encode(["success" => false, "message" => "Variabel koneksi database tidak ditemukan!"]);
        exit();
    }

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $id             = $_POST['id'] ?? $_POST['id_produk'] ?? null;
        $nama           = $_POST['nama_produk'] ?? '';
        $harga_raw      = $_POST['harga'] ?? '0';
        $harga          = preg_replace('/[^0-9]/', '', $harga_raw);
        $deskripsi      = $_POST['deskripsi'] ?? '-';
        $stok           = isset($_POST['stok']) ? (int)preg_replace('/[^0-9]/', '', $_POST['stok']) : 0;
        $kategori_input = $_POST['kategori'] ?? 'Makanan';

        // Validasi data penting
        if (empty($id) || $id === 'null' || empty($nama) || empty($harga)) {
            echo json_encode(["success" => false, "message" => "Data ID, Nama, dan Harga wajib diisi!"]);
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
            
            if (!file_exists($target_dir)) {
                mkdir($target_dir, 0777, true);
            }
            
            $target_file = $target_dir . $nama_file;
            if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
                $update_gambar_query = ", gambar = '$nama_file'";
            }
        }

        // Query Update
        $query = "UPDATE produk SET 
                  kategori_id = '$kategori_id', 
                  nama_produk = '$nama', 
                  deskripsi = '$deskripsi', 
                  harga = '$harga', 
                  stok = '$stok' 
                  $update_gambar_query 
                  WHERE id = '$id'";

        if (mysqli_query($db, $query)) {
            echo json_encode(["success" => true, "message" => "Produk berhasil diperbarui!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal UPDATE: " . mysqli_error($db)]);
        }

    } else {
        echo json_encode(["success" => false, "message" => "Bukan metode POST"]);
    }

} catch (\Throwable $e) {
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