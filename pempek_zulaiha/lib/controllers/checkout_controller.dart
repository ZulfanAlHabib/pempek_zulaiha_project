import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class CheckoutController extends GetxController {
  // Menerima parameter dari CheckoutScreen
  final List<Map<String, dynamic>> keranjang;
  final double totalHarga;
  final String userId;
  final String namaPemesan;
  final String noHpPemesan;
  final String alamat;
  final String latitude;
  final String longitude;

  CheckoutController({
    required this.keranjang,
    required this.totalHarga,
    required this.userId,
    required this.namaPemesan,
    required this.noHpPemesan,
    required this.alamat,
    required this.latitude,
    required this.longitude,
  });

  var isUploading = false.obs;
  var fileName = Rxn<String>();
  PlatformFile? selectedFile;

  // Fungsi untuk memilih bukti pembayaran (File / Gambar)
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        selectedFile = result.files.first;
        fileName.value = selectedFile!.name;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi format Rupiah untuk UI
  String formatRupiah(dynamic price) {
    if (price == null) return 'Rp 0';
    try {
      double numValue =
          double.parse(price.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
      return 'Rp ${numValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp $price';
    }
  }

  // Fungsi utama untuk mengirim pesanan ke backend PHP
  Future<void> kirimPesanan() async {
    isUploading.value = true;

    try {
      // 1. CEK DULU MEMORI LOCAL (SharedPreferences) UNTUK MENDAPATKAN USER_ID YANG SEDANG LOGIN
      final prefs = await SharedPreferences.getInstance();

      // Mengambil ID login nyata dari SharedPreferences
      String? sessionUserId = prefs.getString('id') ??
          prefs.getInt('id')?.toString() ??
          prefs.getString('user_id') ??
          prefs.getInt('user_id')?.toString();

      // Jika SharedPreferences menemukan ID valid, gunakan ID tersebut.
      // Jika tidak, baru gunakan parameter userId bawaan dari screen.
      String finalUserId = (sessionUserId != null && sessionUserId.isNotEmpty)
          ? sessionUserId
          : userId;

      // Debugging log untuk memastikan ID yang terkirim di Debug Console
      print('====================================');
      print('DEBUG CHECKOUT USER ID: $finalUserId');
      print('====================================');

      var uri = Uri.parse('${ApiConfig.baseUrl}/checkout.php');
      var request = http.MultipartRequest('POST', uri);

      // Masukkan field data pesanan
      request.fields['user_id'] = finalUserId;
      request.fields['nama_pemesan'] = namaPemesan;
      request.fields['no_hp_pemesan'] = noHpPemesan;
      request.fields['alamat'] = alamat;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['total_harga'] = totalHarga.toString();

      // Ubah list keranjang menjadi string JSON agar bisa dibaca PHP
      request.fields['items'] = jsonEncode(keranjang);

      // Lampirkan file bukti pembayaran jika ada
      if (selectedFile != null && selectedFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bukti_pembayaran',
            selectedFile!.path!,
          ),
        );
      }

      // Kirim request ke server
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Sukses',
            'Pesanan berhasil dikirim! Menunggu konfirmasi admin.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // NAVIGASI: Kembali ke halaman utama (MainScreen)
          Future.delayed(const Duration(seconds: 1), () {
            Get.until((route) => route.isFirst);
          });
        } else {
          Get.snackbar(
            'Gagal',
            data['message'] ?? 'Terjadi kesalahan pada server.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Gagal terhubung ke server (Status: ${response.statusCode})',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan koneksi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }
}
