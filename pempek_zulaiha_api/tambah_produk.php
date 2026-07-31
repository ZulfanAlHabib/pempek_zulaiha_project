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
    $nama          = isset($_POST['nama_produk']) ? $_POST['nama_produk'] : '';
    $harga         = isset($_POST['harga']) ? $_POST['harga'] : '';
    $deskripsi     = isset($_POST['deskripsi']) ? $_POST['deskripsi'] : '-'; 
    $stok          = isset($_POST['stok']) ? (int)$_POST['stok'] : 0;        
    $kategori_input = isset($_POST['kategori']) ? $_POST['kategori'] : 'Makanan'; 

    if (empty($nama) || empty($harga)) {
        echo json_encode(["success" => false, "message" => "Nama dan Harga wajib diisi"]);
        exit();
    }

    // Konversi Nama Kategori menjadi kategori_id
    $kategori_id = 1; 
    $q_kategori = mysqli_query($db, "SELECT id FROM kategori WHERE nama_kategori = '$kategori_input' LIMIT 1");
    if ($q_kategori && $row = mysqli_fetch_assoc($q_kategori)) {
        $kategori_id = $row['id'];
    }

    // --- PROSES UPLOAD GAMBAR KE FOLDER IMAGES ---
    $gambar = 'default.jpg'; // Nama default jika tidak ada gambar yang diupload
    if (isset($_FILES['gambar']['name']) && $_FILES['gambar']['name'] != '') {
        $nama_file = time() . '_' . basename($_FILES['gambar']['name']);
        
        // Menggunakan folder 'images' sesuai permintaan Anda
        $target_dir = "images/"; 
        $target_file = $target_dir . $nama_file;
        
        // Pindahkan file dari memori sementara ke folder images/
        if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
            $gambar = $nama_file; // Update nama file untuk disimpan ke database
        }
    }

    // Masukkan ke database sesuai struktur tabel produk
    $query = "INSERT INTO produk (kategori_id, nama_produk, deskripsi, harga, stok, gambar) 
              VALUES ('$kategori_id', '$nama', '$deskripsi', '$harga', '$stok', '$gambar')";

    try {
        if (mysqli_query($db, $query)) {
            echo json_encode(["success" => true, "message" => "Produk berhasil ditambahkan!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal INSERT: " . mysqli_error($db)]);
        }
    } catch (Exception $e) {
        echo json_encode(["success" => false, "message" => "Error Query: " . $e->getMessage()]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Bukan metode POST"]);
}
?>