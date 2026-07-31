<?php
// register.php
// Method: POST
// Body (form-data / x-www-form-urlencoded): nama, email, password, no_hp

require "db_connect.php";

$nama = $_POST['nama'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$no_hp = $_POST['no_hp'] ?? '';

if (empty($nama) || empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Nama, email, dan password wajib diisi"]);
    exit();
}

// Cek email sudah terdaftar atau belum
$cek = $conn->prepare("SELECT id FROM users WHERE email = ?");
$cek->bind_param("s", $email);
$cek->execute();
$cek->store_result();

if ($cek->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Email sudah terdaftar"]);
    exit();
}

$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("INSERT INTO users (nama, email, password, no_hp) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $nama, $email, $hashedPassword, $no_hp);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Registrasi berhasil",
        "user" => [
            "id" => $stmt->insert_id,
            "nama" => $nama,
            "email" => $email
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Registrasi gagal: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
