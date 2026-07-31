import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import '../screens/login_screen.dart'; // Pastikan path sesuai

class ProfilController extends GetxController {
  var namaUser = "Memuat...".obs;
  var emailUser = "Memuat...".obs;
  var isLoading = false.obs;

  // Controller untuk form Edit Profil
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    namaUser.value = prefs.getString('nama') ?? 'Pelanggan';
    emailUser.value = prefs.getString('email') ?? 'email@kosong.com';
  }

  Future<void> updateProfil() async {
    isLoading.value = true;
    try {
      var url = Uri.parse('${ApiConfig.baseUrl}/update_profil.php');
      var response = await http.post(url, body: {
        'email_lama': emailUser.value,
        'nama_baru': nameController.text,
        'email_baru': emailController.text,
        'password_baru': passwordController.text,
      });

      var data = json.decode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', nameController.text);
        await prefs.setString('email', emailController.text);

        namaUser.value = nameController.text;
        emailUser.value = emailController.text;

        Get.back(); // Tutup dialog
        Get.snackbar('Sukses', 'Profil & Akun sukses diupdate!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', data['message'] ?? 'Gagal update profil',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error Koneksi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hubungiAdmin() async {
    final Uri whatsappUrl =
        Uri.parse("whatsapp://send?phone=6281234567890&text=Halo%20Admin");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      Get.snackbar('Error', 'WhatsApp tidak ditemukan di HP ini.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.snackbar('Berhasil', 'Berhasil Keluar Akun',
        backgroundColor: Colors.brown, colorText: Colors.white);

    // Kembali paksa ke halaman login (hapus tumpukan history)
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
