<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once 'db_connect.php';

$role = $_POST['role'] ?? 'guest';
$id_user = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;

$response = [];

$query = "SELECT * FROM notifikasi 
          WHERE role_target = 'all' 
             OR role_target = ? 
             OR (id_user = ? AND id_user != 0)
          ORDER BY created_at DESC";

$stmt = mysqli_prepare($conn, $query);

if ($stmt) {
    mysqli_stmt_bind_param($stmt, "si", $role, $id_user);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $notifikasi_list = [];
    while ($row = mysqli_fetch_assoc($result)) {
        // Memastikan key 'tipe_notif' tetap terbaca jika dipanggil Flutter, 
        // dengan mengambil nilai dari kolom 'tipe' di database
        if (isset($row['tipe']) && !isset($row['tipe_notif'])) {
            $row['tipe_notif'] = $row['tipe'];
        }
        $notifikasi_list[] = $row;
    }

    $response = [
        "success" => true,
        "message" => "Data notifikasi berhasil diambil",
        "data" => $notifikasi_list
    ];
    
    mysqli_stmt_close($stmt);
} else {
    $response = [
        "success" => false,
        "message" => "Gagal mengambil notifikasi"
    ];
}

mysqli_close($conn);
echo json_encode($response);
?>