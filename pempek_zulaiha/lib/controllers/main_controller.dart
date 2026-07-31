import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  var isGuest = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isGuest.value = prefs.getBool('isGuest') ?? false;
  }

  void onItemTapped(int index) {
    // Aturan: Jika Tamu (Guest) mencoba membuka Riwayat (index 1), dicegah
    if (isGuest.value && index == 1) {
      Get.snackbar(
        'Akses Ditolak',
        'Silakan login terlebih dahulu untuk melihat riwayat pesanan.',
        backgroundColor: Colors.brown,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    selectedIndex.value = index;
  }
}
