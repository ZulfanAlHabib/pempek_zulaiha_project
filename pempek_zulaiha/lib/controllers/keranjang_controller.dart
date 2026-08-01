import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/checkout_screen.dart';

class KeranjangController extends GetxController {
  var keranjang = <Map<String, dynamic>>[].obs;

  final namaController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();

  var latitude = "0".obs;
  var longitude = "0".obs;
  var userId = "1".obs;
  var isLocating = false.obs;

  KeranjangController(List<Map<String, dynamic>> initialData) {
    keranjang.assignAll(initialData);
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('user_id') ?? '1';

    String namaUser = prefs.getString('nama_user') ??
        prefs.getString('nama') ??
        prefs.getString('username') ??
        '';

    if (namaUser.isNotEmpty) {
      namaController.text = namaUser;
    }

    noHpController.text =
        prefs.getString('no_hp') ?? prefs.getString('telepon') ?? '';
  }

  double get totalHarga {
    double total = 0;
    for (var item in keranjang) {
      double sub = double.tryParse(item['subtotal']?.toString() ?? '0') ?? 0;
      total += sub;
    }
    return total;
  }

  // FUNGSI UNTUK MENGOSONGKAN KERANJANG
  void bersihkanKeranjang() {
    keranjang.clear();
    update();
  }

  void kurangiJumlah(int index) {
    var item = keranjang[index];
    if (item['jumlah'] > 1) {
      item['jumlah'] -= 1;
      item['subtotal'] = item['jumlah'] * item['harga_satuan'];
      keranjang[index] = item; // Trigger update
    } else {
      keranjang.removeAt(index);
    }
  }

  void tambahJumlah(int index) {
    var item = keranjang[index];
    int stok = item['stok'] ?? 99;
    if (item['jumlah'] < stok) {
      item['jumlah'] += 1;
      item['subtotal'] = item['jumlah'] * item['harga_satuan'];
      keranjang[index] = item; // Trigger update
    } else {
      Get.snackbar('Batas Stok', 'Jumlah mencapai batas stok!',
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  Future<void> getLokasiGPS() async {
    isLocating.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Layanan lokasi/GPS pada perangkat belum aktif.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Izin lokasi ditolak.',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Izin lokasi ditolak secara permanen.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude.toString();
      longitude.value = position.longitude.toString();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty)
          addressParts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add(place.locality!);
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty)
          addressParts.add(place.subAdministrativeArea!);

        String alamatFormated = addressParts.join(', ');
        alamatController.text = alamatFormated.isNotEmpty
            ? alamatFormated
            : "${position.latitude}, ${position.longitude}";
      }

      Get.snackbar('Sukses', 'Lokasi & alamat berhasil diperbarui!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLocating.value = false;
    }
  }

  void selesaikanPesanan() {
    if (keranjang.isEmpty) {
      Get.snackbar('Kosong', 'Keranjang Anda masih kosong!',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (alamatController.text.trim().isEmpty) {
      Get.snackbar(
          'Perhatian', 'Silakan isi atau ambil alamat lokasi pengiriman!',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.to(() => CheckoutScreen(
          keranjang: keranjang.toList(),
          totalHarga: totalHarga,
          userId: userId.value,
          namaPemesan: namaController.text,
          noHpPemesan: noHpController.text,
          alamat: alamatController.text,
          latitude: latitude.value,
          longitude: longitude.value,
        ));
  }

  String formatRupiah(double number) {
    return 'Rp ${number.toStringAsFixed(0)}';
  }

  @override
  void onClose() {
    namaController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    super.onClose();
  }
}
