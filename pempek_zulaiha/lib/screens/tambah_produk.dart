import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tambah_produk_controller.dart';

class TambahProduk extends StatelessWidget {
  const TambahProduk({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TambahProdukController());

    return Scaffold(
      appBar: AppBar(
          title: const Text('Tambah Menu Baru',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange[700],
          iconTheme: const IconThemeData(color: Colors.white)),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Upload Gambar
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
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 50, color: Colors.orange),
                              Text('Pilih Gambar',
                                  style: TextStyle(color: Colors.orange)),
                            ],
                          )),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Nama Produk',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                  controller: controller.namaController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 16),

              const Text('Harga',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                  controller: controller.hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 16),

              const Text('Deskripsi (Opsional)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                  controller: controller.deskripsiController,
                  maxLines: 2,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 16),

              const Text('Stok',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              TextField(
                  controller: controller.stokController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 16),

              const Text('Kategori',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.kategoriTerpilih.value,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                    items: controller.kategoriList
                        .map((String k) =>
                            DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: controller.setKategori,
                  )),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.simpanProduk,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Menu',
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
