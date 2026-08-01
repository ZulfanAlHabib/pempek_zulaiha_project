<?php
// Menyembunyikan output error PHP langsung agar tidak merusak format JSON
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");

try {
    require_once 'db_connect.php';

    $db = isset($conn) ? $conn : (isset($koneksi) ? $koneksi : null);

    if (!$db) {
        echo json_encode(["success" => false, "message" => "Koneksi database gagal!"]);
        exit();
    }

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $id = $_POST['id'] ?? null;

        if (empty($id) || $id === 'null') {
            echo json_encode(["success" => false, "message" => "ID Produk tidak ditemukan!"]);
            exit();
        }

        $query = "DELETE FROM produk WHERE id = '$id'";

        if (mysqli_query($db, $query)) {
            echo json_encode(["success" => true, "message" => "Produk berhasil dihapus!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal menghapus produk: " . mysqli_error($db)]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Metode request harus POST"]);
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