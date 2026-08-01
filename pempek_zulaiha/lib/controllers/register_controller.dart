import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class RegisterController extends GetxController {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();

  var isLoading = false.obs;

  Future<void> register() async {
    // Validasi input
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Username dan Password wajib diisi!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/register.php');

      final response = await http.post(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'nama': namaController.text.trim(),
          'email': emailController.text.trim(),
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
          'no_hp': noHpController.text.trim(),
          'alamat': alamatController.text.trim(),
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            Get.snackbar(
              'Sukses',
              data['message'] ?? 'Registrasi berhasil! Silakan login.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );

            // Berpindah kembali ke Halaman Login setelah pendaftaran sukses
            Get.back();
          } else {
            Get.snackbar(
              'Gagal',
              data['message'] ?? 'Registrasi gagal.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error Format Server',
            'Respon dari server bukan JSON valid: ${response.body}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error Server',
          'Status Code: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Koneksi',
        'Tidak dapat terhubung ke server: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    super.onClose();
  }
}
