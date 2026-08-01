<?php
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
        $nama     = $_POST['nama'] ?? $_POST['nama_user'] ?? '';
        $email    = $_POST['email'] ?? '';
        $username = $_POST['username'] ?? '';
        $password = $_POST['password'] ?? '';
        $no_hp    = $_POST['no_hp'] ?? $_POST['telepon'] ?? '-';
        $alamat   = $_POST['alamat'] ?? '-';

        if (empty($username) || empty($password)) {
            echo json_encode(["success" => false, "message" => "Username dan Password wajib diisi!"]);
            exit();
        }

        // Cek duplicate username
        $query_cek = "SELECT id FROM users WHERE username = '$username' LIMIT 1";
        $res_cek   = mysqli_query($db, $query_cek);

        if ($res_cek && mysqli_num_rows($res_cek) > 0) {
            echo json_encode(["success" => false, "message" => "Username sudah terdaftar! Gunakan username lain."]);
            exit();
        }

        // Query Insert
        $query_insert = "INSERT INTO users (nama, email, username, password, no_hp, alamat, role) 
                        VALUES ('$nama', '$email', '$username', '$password', '$no_hp', '$alamat', 'user')";

        if (mysqli_query($db, $query_insert)) {
            echo json_encode([
                "success" => true, 
                "message" => "Akun berhasil dibuat! Silakan login."
            ]);
        } else {
            echo json_encode([
                "success" => false, 
                "message" => "Gagal menyimpan data: " . mysqli_error($db)
            ]);
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
?>
