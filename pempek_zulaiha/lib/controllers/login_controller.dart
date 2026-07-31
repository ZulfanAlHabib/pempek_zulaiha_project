import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import '../screens/main_screen.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var obscurePassword = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Email dan Password tidak boleh kosong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/login.php');
      final response = await http.post(url, body: {
        'email': emailController.text,
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);

          // Mengambil data dari key 'user' sesuai PHP kamu, dan simpan ID secara aman
          var userData = data['user'] ?? {};
          await prefs.setString('id', (userData['id'] ?? '').toString());
          await prefs.setString('nama', userData['nama'] ?? 'Pengguna');
          await prefs.setString(
              'email', userData['email'] ?? emailController.text);
          await prefs.setString('role', userData['role'] ?? 'pelanggan');

          Get.snackbar('Sukses', 'Berhasil Login',
              backgroundColor: Colors.green, colorText: Colors.white);

          Get.offAll(() => const MainScreen());
        } else {
          String errorMessage = (data != null && data['message'] != null)
              ? data['message']
              : 'Gagal login, periksa email dan password';

          Get.snackbar('Gagal', errorMessage,
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi bermasalah: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', 'guest');
    await prefs.setString('nama', 'Tamu');

    Get.snackbar('Info', 'Masuk sebagai Tamu',
        backgroundColor: Colors.blue, colorText: Colors.white);
    Get.offAll(() => const MainScreen());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
