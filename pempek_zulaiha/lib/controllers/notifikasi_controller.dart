import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart'; // Sesuaikan path

class NotifikasiController extends GetxController {
  var role = 'pelanggan'.obs;
  var isGuest = false.obs;
  var isLoading = true.obs;

  // List reaktif untuk menyimpan data notifikasi dari database
  var notifikasiList = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    role.value = prefs.getString('role') ?? 'pelanggan';
    isGuest.value = prefs.getBool('isGuest') ?? false;

    // Jika guest, tidak perlu fetch ke database
    if (isGuest.value) {
      isLoading.value = false;
      return;
    }

    String userId = prefs.getString('id') ?? ''; // Ambil ID user jika ada
    await fetchNotifikasi(userId, role.value);
  }

  Future<void> fetchNotifikasi(String userId, String userRole) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/get_notifikasi.php');
      // Mengirim POST request untuk filter notifikasi
      final response = await http.post(url, body: {
        'user_id': userId,
        'role': userRole,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          notifikasiList.assignAll(data['data']);
        } else {
          notifikasiList.clear();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat notifikasi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk refresh data (Pull to Refresh)
  Future<void> refreshData() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id') ?? '';
    await fetchNotifikasi(userId, role.value);
  }
}
