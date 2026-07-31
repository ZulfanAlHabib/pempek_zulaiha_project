import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../api_config.dart';

class TambahProdukController extends GetxController {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final stokController = TextEditingController();

  var kategoriTerpilih = 'Makanan'.obs;
  final List<String> kategoriList = ['Makanan', 'Minuman', 'Lainnya'];

  var isLoading = false.obs;

  // Variabel reaktif untuk menyimpan file gambar
  var imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pilihGambar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  void setKategori(String? val) {
    if (val != null) kategoriTerpilih.value = val;
  }

  Future<void> simpanProduk() async {
    if (namaController.text.isEmpty || hargaController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Nama dan Harga wajib diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/tambah_produk.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['nama_produk'] = namaController.text;
      request.fields['harga'] = hargaController.text;
      request.fields['kategori'] = kategoriTerpilih.value;
      request.fields['deskripsi'] =
          deskripsiController.text.isNotEmpty ? deskripsiController.text : '-';
      request.fields['stok'] =
          stokController.text.isNotEmpty ? stokController.text : '0';

      if (imageFile.value != null) {
        var pic =
            await http.MultipartFile.fromPath('gambar', imageFile.value!.path);
        request.files.add(pic);
      }

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            Get.snackbar('Sukses', 'Menu berhasil ditambahkan!',
                backgroundColor: Colors.green, colorText: Colors.white);
            Get.back(result: true); // Kembali dan kirim status true
          } else {
            Get.snackbar('Gagal', data['message'] ?? 'Gagal menyimpan',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } catch (e) {
          String errorBalasan = response.body.length > 100
              ? response.body.substring(0, 100)
              : response.body;
          Get.snackbar('Error PHP', errorBalasan,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 5));
        }
      } else {
        Get.snackbar('Error', 'Error server status: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error koneksi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
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
