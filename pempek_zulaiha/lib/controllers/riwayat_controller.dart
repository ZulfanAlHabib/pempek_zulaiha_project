import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class RiwayatController extends GetxController {
  var riwayatList = [].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var userRole = 'pelanggan'.obs;
  var userId = ''.obs;

  final List<String> daftarStatus = [
    'menunggu',
    'diproses',
    'dikirim',
    'selesai',
    'dibatalkan'
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserAndFetchRiwayat();
  }

  Future<void> loadUserAndFetchRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('role') ?? 'pelanggan';

    // Mengambil ID dengan aman dari SharedPreferences
    String rawId = prefs.getString('id') ??
        prefs.getInt('id')?.toString() ??
        prefs.getString('user_id') ??
        prefs.getInt('user_id')?.toString() ??
        '';

    userId.value = rawId.trim();
    fetchRiwayatPesanan();
  }

  Future<void> fetchRiwayatPesanan() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/get_riwayat.php');
      final response = await http.post(url, body: {
        'role': userRole.value,
        'user_id': userId.value,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final parsedData = jsonDecode(response.body);
          if (parsedData['success'] == true) {
            riwayatList.assignAll(parsedData['data']);
          } else {
            errorMessage.value =
                parsedData['message'] ?? 'Gagal memuat riwayat.';
          }
        } catch (e) {
          errorMessage.value =
              'Error Format Data: Pastikan get_riwayat.php merespons JSON valid.';
        }
      } else {
        errorMessage.value =
            'Gagal memuat data (Status ${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Error koneksi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusPesanan(String pesananId, String statusBaru) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/update_status.php');
      final response = await http.post(url, body: {
        'pesanan_id': pesananId,
        'status': statusBaru,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
              'Sukses', 'Status Order #$pesananId diubah menjadi "$statusBaru"',
              backgroundColor: Colors.green, colorText: Colors.white);
          fetchRiwayatPesanan();
        } else {
          Get.snackbar('Gagal', data['message'] ?? 'Gagal mengubah status',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.amber[100]!;
      case 'diproses':
        return Colors.blue[100]!;
      case 'dikirim':
        return Colors.purple[100]!;
      case 'selesai':
        return Colors.green[100]!;
      case 'dibatalkan':
        return Colors.red[100]!;
      default:
        return Colors.orange[100]!;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.amber[900]!;
      case 'diproses':
        return Colors.blue[800]!;
      case 'dikirim':
        return Colors.purple[800]!;
      case 'selesai':
        return Colors.green[800]!;
      case 'dibatalkan':
        return Colors.red[800]!;
      default:
        return Colors.orange[800]!;
    }
  }

  String formatRupiah(dynamic price) {
    if (price == null) return 'Rp 0';
    try {
      double numValue =
          double.parse(price.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
      return 'Rp ${numValue.toStringAsFixed(0)}';
    } catch (e) {
      return 'Rp $price';
    }
  }

  String formatDetailPesanan(Map<String, dynamic> item) {
    dynamic rawDetail = item['detail_pesanan'] ??
        item['pesanan_detail'] ??
        item['items'] ??
        item['detail'] ??
        item['produk'] ??
        item['rincian'] ??
        item['detail_item'] ??
        item['daftar_produk'] ??
        item['list_produk'] ??
        item['kue'] ??
        item['item'];

    if (rawDetail != null && rawDetail.toString().trim().isNotEmpty) {
      if (rawDetail is String) {
        try {
          var decoded = jsonDecode(rawDetail);
          if (decoded is List) return _formatListItems(decoded);
        } catch (e) {
          return rawDetail;
        }
      } else if (rawDetail is List) {
        return _formatListItems(rawDetail);
      }
      return rawDetail.toString();
    }

    List<String> availableKeys = item.keys.toList();
    return 'Rincian item tidak ditemukan.\n\n[Debug Key Server]: ${availableKeys.join(', ')}';
  }

  String _formatListItems(List list) {
    List<String> result = [];
    for (var i in list) {
      if (i is Map) {
        String nama = i['nama_produk'] ??
            i['nama'] ??
            i['nama_kue'] ??
            'Produk ID: ${i['produk_id'] ?? '-'}';
        String qty = i['jumlah']?.toString() ?? i['qty']?.toString() ?? '1';
        String subtotal =
            i['subtotal'] != null ? ' (${formatRupiah(i['subtotal'])})' : '';
        result.add('• $nama x $qty$subtotal');
      } else {
        result.add('• ${i.toString()}');
      }
    }
    return result.isNotEmpty
        ? result.join('\n')
        : 'Rincian item tidak tersedia.';
  }
}
