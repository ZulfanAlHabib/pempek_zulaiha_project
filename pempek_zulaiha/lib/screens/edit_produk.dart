import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_produk_controller.dart';
import '../api_config.dart'; // Sesuaikan path jika perlu

class EditProduk extends StatelessWidget {
  final dynamic produk;

  const EditProduk({Key? key, required this.produk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject Controller dan bawa data produk ke dalamnya
    final controller = Get.put(EditProdukController(produk: produk));

    String gambarLama = produk['gambar'] ?? '';

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Edit Menu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Gambar
              Center(
                child: GestureDetector(
                  onTap: controller.pilihGambar,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Obx(() => controller.imageFile.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(controller.imageFile.value!,
                                fit: BoxFit.cover),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '${ApiConfig.baseUrl}/images/$gambarLama',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 40, color: Colors.orange),
                                  Text('Ganti Gambar',
                                      style: TextStyle(
                                          color: Colors.orange, fontSize: 12)),
                                ],
                              ),
                            ),
                          )),
                  ),
                ),
              ),
              const Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Ketuk gambar untuk mengubah',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              )),
              const SizedBox(height: 16),

              const Text('Nama Produk',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.namaController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white),
              ),
              const SizedBox(height: 16),

              const Text('Harga',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white),
              ),
              const SizedBox(height: 16),

              const Text('Deskripsi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.deskripsiController,
                maxLines: 2,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white),
              ),
              const SizedBox(height: 16),

              const Text('Stok',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white),
              ),
              const SizedBox(height: 16),

              const Text('Kategori',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.kategoriTerpilih.value,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white),
                    items: controller.kategoriList.map((String kategori) {
                      return DropdownMenuItem<String>(
                          value: kategori, child: Text(kategori));
                    }).toList(),
                    onChanged: controller.setKategori,
                  )),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.updateProduk,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Perubahan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
