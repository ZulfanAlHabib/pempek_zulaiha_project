import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../api_config.dart';
import 'home_controller.dart';

class EditProdukController extends GetxController {
  final dynamic produk;

  late TextEditingController namaController;
  late TextEditingController hargaController;
  late TextEditingController deskripsiController;
  late TextEditingController stokController;

  var kategoriTerpilih = 'Makanan'.obs;
  final List<String> kategoriList = ['Makanan', 'Minuman', 'Lainnya'];
  var isLoading = false.obs;

  var imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  EditProdukController({required this.produk});

  // Helper untuk membersihkan nilai harga awal dari desimal (.00)
  String _formatHargaAwal(dynamic rawHarga) {
    if (rawHarga == null) return '0';
    String str = rawHarga.toString().trim();
    double? val = double.tryParse(str);
    if (val != null) {
      return val.toInt().toString(); // Mengubah 4000.00 menjadi "4000"
    }
    return str.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  void onInit() {
    super.onInit();
    namaController =
        TextEditingController(text: produk['nama_produk']?.toString() ?? '');

    // FORMAT HARGA: Pastikan .00 dibuang agar controller hanya berisi angka bulat "4000"
    hargaController =
        TextEditingController(text: _formatHargaAwal(produk['harga']));

    deskripsiController =
        TextEditingController(text: produk['deskripsi']?.toString() ?? '');

    stokController =
        TextEditingController(text: _formatHargaAwal(produk['stok']));

    // Penyesuaian kategori berdasarkan data yang diterima
    String kategoriAwal = produk['kategori']?.toString() ?? 'Makanan';
    if (kategoriList.contains(kategoriAwal)) {
      kategoriTerpilih.value = kategoriAwal;
    } else {
      kategoriTerpilih.value = 'Makanan';
    }
  }

  // Memilih gambar
  Future<void> pilihGambar() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void setKategori(String? newValue) {
    if (newValue != null) {
      kategoriTerpilih.value = newValue;
    }
  }

  // Fungsi menyimpan perubahan ke PHP
  Future<void> updateProduk() async {
    if (namaController.text.trim().isEmpty ||
        hargaController.text.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama dan Harga wajib diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/edit_produk.php');
      var request = http.MultipartRequest('POST', url);

      // Bypass Ngrok Warning Screen
      request.headers['ngrok-skip-browser-warning'] = 'true';

      String idProduk = (produk['id'] ?? produk['id_produk'] ?? '').toString();

      // Olah harga dengan aman: ambil angka saja, abaikan desimal jika ada
      String rawHargaText = hargaController.text.trim();
      double? parsedHargaDouble = double.tryParse(rawHargaText);
      String cleanHarga;
      if (parsedHargaDouble != null) {
        cleanHarga = parsedHargaDouble.toInt().toString();
      } else {
        cleanHarga = rawHargaText.replaceAll(RegExp(r'[^0-9]'), '');
      }

      String rawStokText = stokController.text.trim();
      double? parsedStokDouble = double.tryParse(rawStokText);
      String cleanStok;
      if (parsedStokDouble != null) {
        cleanStok = parsedStokDouble.toInt().toString();
      } else {
        cleanStok = rawStokText.replaceAll(RegExp(r'[^0-9]'), '');
      }

      request.fields['id'] = idProduk;
      request.fields['nama_produk'] = namaController.text.trim();
      request.fields['harga'] = cleanHarga;
      request.fields['kategori'] = kategoriTerpilih.value;
      request.fields['deskripsi'] = deskripsiController.text.trim();
      request.fields['stok'] = cleanStok.isEmpty ? '0' : cleanStok;

      // Jika user memilih gambar baru
      if (imageFile.value != null) {
        var pic =
            await http.MultipartFile.fromPath('gambar', imageFile.value!.path);
        request.files.add(pic);
      }

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          Get.snackbar(
            'Error Server',
            'Respon edit_produk bermasalah (HTML Error)',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            // Panggil ulang data di HomeController secara langsung
            if (Get.isRegistered<HomeController>()) {
              await Get.find<HomeController>().fetchProduk();
            }

            // Kembali ke layar sebelumnya
            Get.back(result: true);

            Get.snackbar(
              'Sukses',
              'Produk berhasil diperbarui!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Gagal',
              data['message'] ?? 'Gagal update produk',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          String errorBalasan = response.body.length > 150
              ? response.body.substring(0, 150)
              : response.body;
          Get.snackbar(
            'Error Respon Server',
            errorBalasan,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Error server status: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error koneksi: $e',
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
    hargaController.dispose();
    deskripsiController.dispose();
    stokController.dispose();
    super.onClose();
  }
}
