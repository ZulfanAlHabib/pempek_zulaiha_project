<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "pempek_zulaiha");

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Koneksi database gagal."]));
}

$pesanan_id = $_POST['pesanan_id'] ?? '';
$status     = $_POST['status'] ?? '';

if (!empty($pesanan_id) && !empty($status)) {
    $query = "UPDATE pesanan SET status = '$status' WHERE id = '$pesanan_id'";
    
    if (mysqli_query($conn, $query)) {
        echo json_encode(["success" => true, "message" => "Status pesanan berhasil diperbarui."]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal memperbarui status: " . mysqli_error($conn)]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data ID pesanan atau status tidak boleh kosong."]);
}

$conn->close();
?>