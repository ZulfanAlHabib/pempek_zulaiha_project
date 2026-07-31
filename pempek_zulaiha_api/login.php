<?php
// login.php
// Method: POST
// Body: email, password

require "db_connect.php";

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Email dan password wajib diisi"]);
    exit();
}

// PERBAIKAN DI SINI: Tambahkan 'role' ke dalam daftar SELECT
$stmt = $conn->prepare("SELECT id, nama, email, password, role FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Email tidak ditemukan"]);
    exit();
}

$row = $result->fetch_assoc();

if (password_verify($password, $row['password'])) {
    echo json_encode([
        "success" => true,
        "message" => "Login berhasil",
        "user" => [
            "id" => $row['id'],
            "nama" => $row['nama'],
            "email" => $row['email'],
            "role" => $row['role']
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Password salah"]);
}

$stmt->close();
$conn->close();
?>