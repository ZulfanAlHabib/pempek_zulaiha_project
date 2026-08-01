<?php
// Header CORS agar tidak diblokir Ngrok & Flutter
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, ngrok-skip-browser-warning");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

// Tangani request preflight OPTIONS dari Flutter/Browser
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$user = "root";       // Default XAMPP adalah root
$pass = "";           // Default XAMPP adalah kosong (tanpa spasi)
$db   = "pempek_zulaiha"; // PENTING: Ganti dengan nama database Anda yang sebenarnya!

$conn = mysqli_connect($host, $user, $pass, $db);

// Jika koneksi gagal, kembalikan pesan error dalam format JSON yang bisa dibaca Flutter
if (!$conn) {
    header("Content-Type: application/json; charset=UTF-8");
    echo json_encode([
        "success" => false, 
        "message" => "Gagal terhubung ke database: " . mysqli_connect_error()
    ]);
    exit(); // Hentikan eksekusi agar tidak merusak file lain
}
?>