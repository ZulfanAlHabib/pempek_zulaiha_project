import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifikasi_controller.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotifikasiController());

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Notifikasi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[700],
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Obx(() {
        // Tampilkan loading saat pertama kali fetch
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.orange));
        }

        // Tampilan khusus untuk Guest
        if (controller.isGuest.value) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: const ListTile(
                  leading: Icon(Icons.account_circle,
                      color: Colors.orange, size: 36),
                  title: Text('Selamat Datang di Pempek Zulaiha!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Silakan Login terlebih dahulu untuk dapat melakukan checkout pesanan dan menikmati fitur lengkap.'),
                ),
              ),
            ],
          );
        }

        // Tampilan jika tidak ada notifikasi di database
        if (controller.notifikasiList.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 150),
                Center(
                  child: Text(
                    'Belum ada notifikasi.',
                    style: TextStyle(color: Colors.brown, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        // Tampilan list dinamis dari tabel database (Pull to refresh standar)
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.notifikasiList.length,
            itemBuilder: (context, index) {
              final notif = controller.notifikasiList[index];

              // Asumsi kolom di tabel database: judul, pesan, tipe_notif, created_at
              String judul = notif['judul'] ?? 'Notifikasi';
              String pesan = notif['pesan'] ?? '';
              String tipe = notif['tipe_notif'] ??
                  'Info'; // misal: Promo, Pesanan, Sistem

              IconData iconData = Icons.notifications;
              Color iconColor = Colors.orange;

              // Kustomisasi icon berdasarkan tipe notifikasi di DB
              if (tipe.toLowerCase() == 'promo') {
                iconData = Icons.local_offer;
                iconColor = Colors.red;
              } else if (tipe.toLowerCase() == 'pesanan') {
                iconData = Icons.shopping_bag;
                iconColor = Colors.green;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(iconData, color: iconColor, size: 36),
                  title: Text(judul,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(pesan),
                  trailing: Text(tipe,
                      style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
