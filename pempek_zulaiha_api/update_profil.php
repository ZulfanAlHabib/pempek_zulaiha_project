<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Menggunakan db_connect.php untuk mencegah FormatException!
include 'db_connect.php'; 

$email_lama = $_POST['email_lama'] ?? '';
$nama_baru = $_POST['nama_baru'] ?? '';
$email_baru = $_POST['email_baru'] ?? '';
$password_baru = $_POST['password_baru'] ?? '';

if (!empty($email_lama) && !empty($nama_baru) && !empty($email_baru)) {
    
    // Jika kolom password diisi, update passwordnya juga
    if (!empty($password_baru)) {
        // (Catatan: Jika login Anda menggunakan md5, ubah menjadi md5($password_baru))
        $sql = "UPDATE users SET nama = '$nama_baru', email = '$email_baru', password = '$password_baru' WHERE email = '$email_lama'";
    } else {
        // Jika password dikosongkan, update nama dan email saja
        $sql = "UPDATE users SET nama = '$nama_baru', email = '$email_baru' WHERE email = '$email_lama'";
    }
    
    if (mysqli_query($conn, $sql)) {
        echo json_encode(["success" => true, "message" => "Profil berhasil diperbarui"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal: " . mysqli_error($conn)]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak boleh kosong"]);
}
?>