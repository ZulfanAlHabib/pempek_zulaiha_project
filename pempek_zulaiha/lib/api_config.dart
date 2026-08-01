class ApiConfig {
  // Base URL Ngrok
  static const String baseUrl =
      "https://f427-180-252-174-135.ngrok-free.app/pempek_zulaiha_api";

  // Header wajib bypass warning Ngrok
  static const Map<String, String> headers = {
    'ngrok-skip-browser-warning': 'true',
    'Accept': 'application/json',
  };

  // 1. Helper untuk URL Foto Produk (Folder: images)
  static String getProductImageUrl(String fileName) {
    return "$baseUrl/images/$fileName";
  }

  // 2. Helper untuk URL Bukti Pembayaran (Folder: uploads)
  static String getPaymentProofUrl(String fileName) {
    return "$baseUrl/uploads/$fileName";
  }
}
