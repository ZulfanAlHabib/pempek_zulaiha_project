import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../api_config.dart'; // Sesuaikan path jika perlu

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

  @override
  void onInit() {
    super.onInit();
    namaController = TextEditingController(text: produk['nama_produk'] ?? '');
    hargaController =
        TextEditingController(text: produk['harga']?.toString() ?? '');
    deskripsiController =
        TextEditingController(text: produk['deskripsi'] ?? '');
    stokController =
        TextEditingController(text: produk['stok']?.toString() ?? '0');

    // Penyesuaian kategori berdasarkan data yang diterima
    String kategoriAwal = produk['kategori'] ?? 'Makanan';
    if (kategoriList.contains(kategoriAwal)) {
      kategoriTerpilih.value = kategoriAwal;
    } else {
      kategoriTerpilih.value = 'Makanan';
    }
  }

  Future<void> pilihGambar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  void setKategori(String? newValue) {
    if (newValue != null) {
      kategoriTerpilih.value = newValue;
    }
  }

  Future<void> updateProduk() async {
    if (namaController.text.isEmpty || hargaController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Nama dan Harga wajib diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/edit_produk.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['id'] = produk['id'].toString();
      request.fields['nama_produk'] = namaController.text;
      request.fields['harga'] = hargaController.text;
      request.fields['kategori'] = kategoriTerpilih.value;
      request.fields['deskripsi'] = deskripsiController.text;
      request.fields['stok'] = stokController.text;

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
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            Get.snackbar('Sukses', 'Produk berhasil diperbarui!',
                backgroundColor: Colors.green, colorText: Colors.white);
            Get.back(result: true); // Kembali dan beri sinyal update sukses
          } else {
            Get.snackbar('Gagal', data['message'] ?? 'Gagal update produk',
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
