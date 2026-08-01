import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';
import '../api_config.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({Key? key}) : super(key: key);

  void _tampilkanDetailPesanan(BuildContext context,
      RiwayatController controller, Map<String, dynamic> item) {
    String pesananId = item['id']?.toString() ?? '0';
    String namaPemesan = item['nama_pemesan'] ?? item['nama'] ?? 'Pelanggan';
    String noHp = item['no_hp_pemesan'] ?? item['no_hp'] ?? '-';
    String alamat = item['alamat'] ?? 'Alamat tidak dicantumkan';
    String lat = item['latitude']?.toString() ?? '0';
    String long = item['longitude']?.toString() ?? '0';
    String detailPesanan = controller.formatDetailPesanan(item);
    String tanggal = item['created_at'] ?? item['tanggal'] ?? '-';
    String buktiBayar = item['bukti_pembayaran'] ?? '';

    // Perbaikan URL Gambar agar tidak terduplikasi path /uploads/
    String buktiBayarUrl = '';
    if (buktiBayar.isNotEmpty) {
      if (buktiBayar.startsWith('http')) {
        buktiBayarUrl = buktiBayar;
      } else if (buktiBayar.startsWith('uploads/')) {
        buktiBayarUrl = '${ApiConfig.baseUrl}/$buktiBayar';
      } else {
        buktiBayarUrl = '${ApiConfig.baseUrl}/uploads/$buktiBayar';
      }
    }

    // Mengambil status dengan proteksi jika kosong/null agar default menjadi 'menunggu'
    String statusAwal =
        (item['status'] != null && item['status'].toString().trim().isNotEmpty)
            ? item['status'].toString()
            : 'menunggu';
    RxString statusCurrent = statusAwal.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Order #$pesananId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    // BADGE STATUS DENGAN TEKS YANG SELALU TAMPIL JELAS
                    Obx(() {
                      String teksStatus = statusCurrent.value.trim().isEmpty
                          ? 'MENUNGGU'
                          : statusCurrent.value.toUpperCase();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              controller.getStatusBgColor(statusCurrent.value),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          teksStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: controller
                                .getStatusTextColor(statusCurrent.value),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tanggal: $tanggal',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 25, thickness: 1),

                // INFORMASI PELANGGAN
                const Text(
                  'Data Pelanggan & Pengiriman',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.brown),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.person, 'Nama', namaPemesan),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, 'No. HP', noHp),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'Alamat', alamat),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.gps_fixed, 'GPS (Lat, Long)', '$lat, $long'),

                const Divider(height: 25, thickness: 1),

                // RINCIAN PESANAN
                const Text(
                  'Rincian Pesanan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.brown),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    detailPesanan,
                    style: const TextStyle(
                        fontSize: 13, height: 1.4, color: Colors.black87),
                  ),
                ),
                if (buktiBayar.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Bukti Pembayaran Pelanggan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.brown),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buktiBayar.toLowerCase().endsWith('.pdf')
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.grey[200],
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Berkas PDF: $buktiBayar',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.network(
                            headers: ApiConfig.headers,
                            buktiBayarUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.grey[200],
                              child: const Text('Gagal memuat foto bukti bayar',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      controller.formatRupiah(item['total_harga']),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),

                // FITUR KHUSUS ADMIN: UBAH STATUS
                if (controller.userRole.value == 'admin') ...[
                  const Divider(height: 25, thickness: 1),
                  const Text(
                    'Ubah Status Pesanan (Admin)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.brown),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: controller
                                  .getStatusTextColor(statusCurrent.value)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.daftarStatus
                                    .contains(statusCurrent.value.toLowerCase())
                                ? statusCurrent.value.toLowerCase()
                                : 'menunggu',
                            items: controller.daftarStatus.map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: controller.getStatusBgColor(val),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        val.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: controller
                                              .getStatusTextColor(val),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? val) {
                              if (val != null) {
                                statusCurrent.value = val;
                                controller.updateStatusPesanan(pesananId, val);
                              }
                            },
                          ),
                        ),
                      )),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.orange[700]),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiwayatController());

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              headers: ApiConfig.headers,
              '${ApiConfig.baseUrl}/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.store, color: Colors.white),
            ),
          ),
        ),
        title: Obx(() => Text(
              controller.userRole.value == 'admin'
                  ? 'Riwayat Pesanan'
                  : 'Riwayat Belanja',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )),
        centerTitle: true,
        backgroundColor: Colors.orange[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetchRiwayatPesanan,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.orange));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
              child: Text(controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red)));
        }
        if (controller.riwayatList.isEmpty) {
          return Center(
            child: Text(
              controller.userRole.value == 'admin'
                  ? 'Belum ada pesanan masuk dari pelanggan.'
                  : 'Anda belum memiliki riwayat pembelian.',
              style: const TextStyle(color: Colors.brown, fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRiwayatPesanan,
          color: Colors.orange,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.riwayatList.length,
            itemBuilder: (context, index) {
              final item =
                  Map<String, dynamic>.from(controller.riwayatList[index]);
              String namaPemesan = item['nama_pemesan'] ??
                  item['nama'] ??
                  'Pelanggan ID: ${item['user_id'] ?? 'Tamu'}';
              String detailPesanan = controller.formatDetailPesanan(item);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      _tampilkanDetailPesanan(context, controller, item),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${item['id'] ?? '0'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item['created_at'] ?? item['tanggal'] ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        if (controller.userRole.value == 'admin') ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text(
                                namaPemesan,
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 20),
                        Text(
                          detailPesanan,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.touch_app,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  'Ketuk untuk detail',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                            Text(
                              controller.formatRupiah(item['total_harga']),
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
