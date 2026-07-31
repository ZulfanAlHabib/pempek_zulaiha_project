<?php
// Mengatur header agar merespons dalam format JSON
header("Content-Type: application/json; charset=UTF-8");

// Menyertakan file koneksi database (sesuaikan nama file koneksi Anda, misal: koki.php, db.php, atau koneksi.php)
include 'db_connect.php'; 

// Memeriksa apakah request menggunakan metode POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Mendapatkan ID produk dari parameter POST yang dikirim oleh Flutter
    $id = isset($_POST['id']) ? mysqli_real_escape_string($conn, $_POST['id']) : '';

    // Validasi jika ID kosong
    if (empty($id)) {
        echo json_encode([
            "success" => false,
            "message" => "ID produk tidak boleh kosong."
        ]);
        exit();
    }

    // (Opsional) Ambil nama file gambar terlebih dahulu jika Anda ingin 
    // menghapus file gambarnya juga dari folder server agar tidak menumpuk.
    $query_img = mysqli_query($conn, "SELECT gambar_url FROM produk WHERE id = '$id'");
    if ($row = mysqli_fetch_assoc($query_img)) {
        $gambar = $row['gambar_url'];
        // Jika file gambarnya ada di folder images, hapus file fisiknya
        if (!empty($gambar) && file_exists("images/$gambar")) {
            unlink("images/$gambar");
        }
    }

    // Query untuk menghapus data produk berdasarkan ID dari database
    $query = "DELETE FROM produk WHERE id = '$id'";
    $execute = mysqli_query($conn, $query);

    if ($execute) {
        // Jika penghapusan berhasil
        echo json_encode([
            "success" => true,
            "message" => "Produk berhasil dihapus."
        ]);
    } else {
        // Jika query gagal dieksekusi
        echo json_encode([
            "success" => false,
            "message" => "Gagal menghapus produk dari database: " . mysqli_error($conn)
        ]);
    }

} else {
    // Jika diakses selain menggunakan metode POST
    echo json_encode([
        "success" => false,
        "message" => "Metode request tidak valid."
    ]);
}
?>