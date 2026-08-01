import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/keranjang_controller.dart';
import '../api_config.dart';

class KeranjangScreen extends StatelessWidget {
  final List<Map<String, dynamic>> keranjang;

  const KeranjangScreen({Key? key, required this.keranjang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KeranjangController(keranjang));

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Keranjang Belanja',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.keranjang.isEmpty) {
                return const Center(
                    child: Text('Keranjang masih kosong',
                        style: TextStyle(color: Colors.brown)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.keranjang.length,
                itemBuilder: (context, index) {
                  final item = controller.keranjang[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          headers: ApiConfig.headers,
                          '${ApiConfig.baseUrl}/images/${item['gambar']}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.fastfood,
                                  size: 40, color: Colors.orange),
                        ),
                      ),
                      title: Text(item['nama_produk'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${controller.formatRupiah(item['harga_satuan'])} x ${item['jumlah']} = ${controller.formatRupiah(item['subtotal'])}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.orange),
                            onPressed: () => controller.kurangiJumlah(index),
                          ),
                          Text('${item['jumlah']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.orange),
                            onPressed: () => controller.tambahJumlah(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3))
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Pengiriman',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller.namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pemesan',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No. HP',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => TextField(
                        controller: controller.alamatController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Alamat Pengiriman',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: controller.isLocating.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.my_location,
                                    color: Colors.orange),
                            onPressed: controller.isLocating.value
                                ? null
                                : controller.getLokasiGPS,
                          ),
                        ),
                      )),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Obx(() => Text(
                            controller.formatRupiah(controller.totalHarga),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800]),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: controller.selesaikanPesanan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Selesaikan Pesanan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
