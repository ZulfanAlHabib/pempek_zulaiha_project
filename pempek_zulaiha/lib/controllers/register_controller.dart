import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart'; // Sesuaikan path utils/api_config.dart

class RegisterController extends GetxController {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final noHpController = TextEditingController();

  var isLoading = false.obs;

  Future<void> register() async {
    isLoading.value = true;
    const String apiUrl = "${ApiConfig.baseUrl}/register.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'nama': namaController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'no_hp': noHpController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.snackbar('Sukses', 'Registrasi Berhasil! Silakan Login.',
              backgroundColor: Colors.green, colorText: Colors.white);
          Get.back(); // Kembali ke halaman login
        } else {
          Get.snackbar('Gagal', data['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan koneksi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    noHpController.dispose();
    super.onClose();
  }
}
