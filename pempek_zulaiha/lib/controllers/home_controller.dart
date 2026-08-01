import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart'; // Sesuaikan path jika perlu

class HomeController extends GetxController {
  var produkList = [].obs;
  var filteredProdukList = [].obs;
  var isLoading = true.obs;
  var userRole = 'pelanggan'.obs;
  var selectedKategori = 'Semua'.obs;
  var showAllProducts = false.obs;
  var searchQuery = ''.obs;

  final searchController = TextEditingController();
  final bannerController = PageController();

  var keranjangList = <Map<String, dynamic>>[].obs;
  var currentBannerIndex = 0.obs;

  final List<String> bannerList = ['informasi', 'informasi2'];

  final List<Map<String, dynamic>> kategoriList = [
    {'nama': 'Semua', 'icon': Icons.grid_view},
    {'nama': 'Makanan', 'icon': Icons.fastfood},
    {'nama': 'Minuman', 'icon': Icons.local_drink},
    {'nama': 'Lainnya', 'icon': Icons.category},
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserRole();
    fetchProduk();
  }

  @override
  void onClose() {
    searchController.dispose();
    bannerController.dispose();
    super.onClose();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('role') ?? 'pelanggan';
  }

  Future<void> fetchProduk() async {
    isLoading.value = true;
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse('${ApiConfig.baseUrl}/get_produk.php?t=$timestamp');
      final response = await http.get(
        url,
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          Get.snackbar(
              'Error Server', 'Respon get_produk bermasalah (HTML Error)',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          produkList.assignAll(data['data']);
          applyFilter();
          produkList.refresh();
          filteredProdukList.refresh();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat produk: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    String query = searchController.text.toLowerCase().trim();
    searchQuery.value = query; // Update untuk memicu UI (tombol silang)
    String selected = selectedKategori.value.toLowerCase().trim();

    var filtered = produkList.where((produk) {
      String nama = (produk['nama_produk'] ?? '').toString().toLowerCase();
      String kategori = (produk['kategori'] ??
              produk['jenis'] ??
              produk['nama_kategori'] ??
              '')
          .toString()
          .toLowerCase();
      String deskripsi = (produk['deskripsi'] ?? '').toString().toLowerCase();

      bool matchesSearch =
          query.isEmpty || nama.contains(query) || deskripsi.contains(query);

      bool matchesKategori = false;
      if (selectedKategori.value == 'Semua') {
        matchesKategori = true;
      } else if (selected == 'makanan') {
        matchesKategori = kategori.contains('makanan') ||
            kategori.contains('pempek') ||
            nama.contains('pempek') ||
            (!kategori.contains('minuman') &&
                !kategori.contains('cuko') &&
                !kategori.contains('pelengkap') &&
                !nama.contains('es ') &&
                !nama.contains('teh') &&
                !nama.contains('jus') &&
                !nama.contains('cuko'));
      } else if (selected == 'minuman') {
        matchesKategori = kategori.contains('minuman') ||
            nama.contains('es ') ||
            nama.contains('teh') ||
            nama.contains('jus') ||
            nama.contains('sirup') ||
            nama.contains('air');
      } else if (selected == 'lainnya') {
        matchesKategori = kategori.contains('lain') ||
            kategori.contains('cuko') ||
            kategori.contains('pelengkap') ||
            nama.contains('cuko') ||
            nama.contains('pelengkap') ||
            nama.contains('sambal') ||
            nama.contains('kerupuk');
      } else {
        matchesKategori =
            kategori.contains(selected) || nama.contains(selected);
      }

      return matchesSearch && matchesKategori;
    }).toList();

    filteredProdukList.assignAll(filtered);
    filteredProdukList.refresh();
  }

  List<dynamic> get rekomendasiProdukList {
    List<dynamic> flagged = filteredProdukList.where((p) {
      var isRekom = p['is_rekomendasi'] ??
          p['rekomendasi'] ??
          p['is_popular'] ??
          p['terlaris'];
      return isRekom == 1 ||
          isRekom == '1' ||
          isRekom == true ||
          isRekom == 'true';
    }).toList();

    if (flagged.isNotEmpty) {
      return flagged;
    }

    List<dynamic> sortedList = List.from(filteredProdukList);
    sortedList.sort((a, b) {
      int stokA = int.tryParse(a['stok']?.toString() ?? '0') ?? 0;
      int stokB = int.tryParse(b['stok']?.toString() ?? '0') ?? 0;
      return stokB.compareTo(stokA);
    });

    return sortedList;
  }

  // Format Rupiah yang menangani angka desimal (misal "4000.00")
  String formatRupiah(String price) {
    try {
      double parsedDouble = double.parse(price);
      int valInt = parsedDouble.toInt();
      return 'Rp $valInt';
    } catch (e) {
      return 'Rp $price';
    }
  }

  int get totalJumlahItemKeranjang {
    return keranjangList.fold(
        0, (sum, item) => sum + (item['jumlah'] as int? ?? 0));
  }

  void setKategori(String kategori) {
    selectedKategori.value = kategori;
    showAllProducts.value = false;
    applyFilter();
  }

  Future<void> hapusProduk(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/hapus_produk.php');
      final response = await http.post(
        url,
        headers: {'ngrok-skip-browser-warning': 'true'},
        body: {'id': id},
      );

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          Get.snackbar('Error Server', 'Respon server bermasalah (HTML Error)',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar('Sukses', 'Produk berhasil dihapus',
              backgroundColor: Colors.green, colorText: Colors.white);
          fetchProduk();
        } else {
          Get.snackbar('Gagal', data['message'] ?? 'Gagal menghapus',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Server status: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void tambahKeKeranjang(dynamic produk) {
    int stok = int.tryParse(produk['stok']?.toString() ?? '0') ?? 0;
    if (stok <= 0) {
      Get.snackbar('Habis', 'Maaf, stok produk ini sudah habis!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    double hargaSatuan =
        double.tryParse(produk['harga']?.toString() ?? '0') ?? 0;

    int index = keranjangList
        .indexWhere((item) => item['id'].toString() == produk['id'].toString());

    if (index >= 0) {
      if (keranjangList[index]['jumlah'] < stok) {
        keranjangList[index]['jumlah'] += 1;
        keranjangList[index]['subtotal'] =
            keranjangList[index]['jumlah'] * hargaSatuan;
        keranjangList.refresh(); // PENTING: Memaksa GetX memperbarui UI List
      } else {
        Get.snackbar('Batas Stok', 'Jumlah melebihi stok tersedia!',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
    } else {
      keranjangList.add({
        'id': produk['id'],
        'nama_produk': produk['nama_produk'],
        'harga_satuan': hargaSatuan,
        'jumlah': 1,
        'subtotal': hargaSatuan,
        'stok': stok,
        'gambar': produk['gambar']
      });
    }

    Get.snackbar(
        'Keranjang', '${produk['nama_produk']} ditambahkan ke keranjang',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 800));
  }
}
