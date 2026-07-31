import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutScreen extends StatelessWidget {
  // 1. DEKLARASI VARIABEL PEMANTER YANG DITERIMA DARI KERANJANG
  final List<Map<String, dynamic>> keranjang;
  final double totalHarga;
  final String userId;
  final String namaPemesan;
  final String noHpPemesan;
  final String alamat;
  final String latitude;
  final String longitude;

  // 2. CONSTRUCTOR DENGAN NAMED PARAMETERS
  const CheckoutScreen({
    Key? key,
    required this.keranjang,
    required this.totalHarga,
    required this.userId,
    required this.namaPemesan,
    required this.noHpPemesan,
    required this.alamat,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject Controller dengan memasukkan parameter dari constructor
    final controller = Get.put(CheckoutController(
      keranjang: keranjang,
      totalHarga: totalHarga,
      userId: userId,
      namaPemesan: namaPemesan,
      noHpPemesan: noHpPemesan,
      alamat: alamat,
      latitude: latitude,
      longitude: longitude,
    ));

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Konfirmasi & Pembayaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rincian Pemesan
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Pengiriman',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text('Nama: $namaPemesan'),
                    Text('No. HP: $noHpPemesan'),
                    Text('Alamat: $alamat'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Ringkasan Pembayaran
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      controller.formatRupiah(totalHarga),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange[800]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section Unggah Bukti Pembayaran
            const Text('Unggah Bukti Pembayaran',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.brown)),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.pickFile,
                    icon: const Icon(Icons.upload_file, color: Colors.orange),
                    label: const Text('Pilih Foto / File (JPG, PNG, PDF)'),
                  ),
                  Obx(() {
                    if (controller.fileName.value != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'File Terpilih: ${controller.fileName.value}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Kirim Pesanan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isUploading.value
                        ? null
                        : controller.kirimPesanan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isUploading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Kirim & Bayar Sekarang',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
