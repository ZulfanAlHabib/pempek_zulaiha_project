import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pempek_zulaiha/api_config.dart';
import 'package:pempek_zulaiha/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _pindahKeLogin();
  }

  // Fungsi untuk otomatis pindah halaman
  void _pindahKeLogin() async {
    // Beri jeda waktu 3 detik agar logo terlihat
    await Future.delayed(const Duration(seconds: 3));
    Get.off(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50], // Background senada dengan tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Memanggil gambar logo.png menggunakan ApiConfig
            Image.network(
              headers: ApiConfig.headers,
              '${ApiConfig.baseUrl}/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              // Jika gambar gagal dimuat, tampilkan icon alternatif
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.orange,
                );
              },
            ),
            const SizedBox(height: 24),

            // Nama Aplikasi
            Text(
              'Pempek Zulaiha',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 40),

            // Indikator Loading berputar
            const CircularProgressIndicator(
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
