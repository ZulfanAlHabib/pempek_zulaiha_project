import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../api_config.dart';
import 'edit_produk.dart';
import 'keranjang_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // FUNGSI MENAMPILKAN DETAIL PRODUK SAAT CARD DIKLIK (TETAP DI VIEW KARENA INI MURNI UI)
  void _tampilkanDetailProduk(
      BuildContext context, HomeController controller, dynamic produk) {
    String nama = produk['nama_produk'] ?? 'Detail Produk';
    String harga = controller.formatRupiah(produk['harga']?.toString() ?? '0');
    String deskripsi =
        produk['deskripsi'] ?? 'Tidak ada deskripsi untuk produk ini.';
    String stok = produk['stok']?.toString() ?? '0';
    String gambar = produk['gambar'] ?? 'default.jpg';
    int stokInt = int.tryParse(stok) ?? 0;
    bool isHabis = stokInt <= 0;

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
                // Gambar Produk Full di Modal Detail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${ApiConfig.baseUrl}/images/$gambar',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.orange[100],
                      child: const Icon(Icons.fastfood,
                          size: 60, color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    Text(
                      harga,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      isHabis ? 'Stok Habis' : 'Stok Tersedia: $stok',
                      style: TextStyle(
                        color: isHabis ? Colors.red : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 25, thickness: 1),
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.brown),
                ),
                const SizedBox(height: 6),
                Text(
                  deskripsi,
                  style: const TextStyle(
                      fontSize: 13, height: 1.4, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Obx(() => controller.userRole.value == 'admin'
                    ? SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            Navigator.pop(context);
                            Get.to(() => EditProduk(produk: produk))
                                ?.then((res) {
                              if (res == true) controller.fetchProduk();
                            });
                          },
                          child: const Text('Edit Produk Ini',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isHabis ? Colors.grey : Colors.orange[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isHabis
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  controller.tambahKeKeranjang(produk);
                                },
                          child: Text(
                            isHabis ? 'Stok Habis' : 'Tambah ke Keranjang',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _konfirmasiHapus(
      BuildContext context, HomeController controller, String id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus produk "$nama"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.hapusProduk(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              '${ApiConfig.baseUrl}/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.store, color: Colors.white),
            ),
          ),
        ),
        title: const Text('Pempek Zulaiha',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange[700],
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () async {
                    final result = await Get.to(
                      () => KeranjangScreen(
                          keranjang: controller.keranjangList.toList()),
                    );
                    if (result == true) {
                      controller.keranjangList.clear();
                      controller.fetchProduk();
                    }
                  },
                ),
                Obx(() {
                  if (controller.totalJumlahItemKeranjang > 0) {
                    return Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${controller.totalJumlahItemKeranjang}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchProduk,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= 1. SEARCH BAR =================
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Obx(() => TextField(
                      controller: controller.searchController,
                      onChanged: (val) => controller.applyFilter(),
                      decoration: InputDecoration(
                        hintText: 'Cari pempek favoritmu...',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.orange),
                        suffixIcon: controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  controller.searchController.clear();
                                  controller.applyFilter();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.orangeAccent, width: 0.5),
                        ),
                      ),
                    )),
              ),

              // ================= 2. BANNER INFORMASI SLIDER =================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PageView.builder(
                              controller: controller.bannerController,
                              onPageChanged: (index) {
                                controller.currentBannerIndex.value = index;
                              },
                              itemCount: controller.bannerList.length,
                              itemBuilder: (context, index) {
                                String bannerName =
                                    controller.bannerList[index];
                                return Image.network(
                                  '${ApiConfig.baseUrl}/images/$bannerName.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      '${ApiConfig.baseUrl}/images/$bannerName.jpg',
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        height: 160,
                                        color: Colors.orangeAccent,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.campaign,
                                                  size: 40,
                                                  color: Colors.white),
                                              const SizedBox(height: 4),
                                              Text('Informasi ${index + 1}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Obx(() => controller.currentBannerIndex.value > 0
                              ? Positioned(
                                  left: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.bannerController
                                            .previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.arrow_back_ios_new,
                                            size: 14,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                          Obx(() => controller.currentBannerIndex.value <
                                  controller.bannerList.length - 1
                              ? Positioned(
                                  right: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.bannerController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Indikator Dots Banner
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.bannerList.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width:
                                  controller.currentBannerIndex.value == index
                                      ? 16
                                      : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    controller.currentBannerIndex.value == index
                                        ? Colors.orange[700]
                                        : Colors.orange[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              // ================= 3. KATEGORI =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Kategori',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.kategoriList.length,
                  itemBuilder: (context, index) {
                    final item = controller.kategoriList[index];
                    return Obx(() {
                      bool isSelected =
                          controller.selectedKategori.value == item['nama'];
                      return GestureDetector(
                        onTap: () => controller.setKategori(item['nama']),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.orange[700] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange[700]!
                                  : Colors.orangeAccent.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(item['icon'],
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.orange),
                              const SizedBox(width: 6),
                              Text(
                                item['nama'],
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.brown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ================= 4. HEADER DYNAMIC =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() {
                  bool isSemuaCategory =
                      controller.selectedKategori.value == 'Semua';
                  bool canExpand = controller.rekomendasiProdukList.length >= 5;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSemuaCategory
                            ? (controller.showAllProducts.value
                                ? 'Semua Produk'
                                : 'Rekomen Menu')
                            : 'Daftar ${controller.selectedKategori.value}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown),
                      ),
                      if (isSemuaCategory)
                        GestureDetector(
                          onTap: canExpand
                              ? () => controller.showAllProducts.value =
                                  !controller.showAllProducts.value
                              : null,
                          child: Text(
                            controller.showAllProducts.value
                                ? 'Sembunyikan'
                                : 'Lihat Semua',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color:
                                  canExpand ? Colors.orange[800] : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 10),

              // ================= 5. DAFTAR KATALOG / REKOMEN MENU =================
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.orange)),
                  );
                }

                if (controller.filteredProdukList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Center(
                        child: Text(
                            'Produk tidak ditemukan untuk kategori ini.',
                            style: TextStyle(color: Colors.brown))),
                  );
                }

                bool isSemuaCategory =
                    controller.selectedKategori.value == 'Semua';
                List<dynamic> displayedProducts = isSemuaCategory
                    ? (controller.showAllProducts.value
                        ? controller.filteredProdukList
                        : controller.rekomendasiProdukList.take(4).toList())
                    : controller.filteredProdukList;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(
                        context, controller, displayedProducts[index]);
                  },
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, HomeController controller, dynamic produk) {
    String namaProduk = produk['nama_produk'] ?? 'Nama Produk';
    String hargaProduk = produk['harga']?.toString() ?? '0';
    String deskripsiProduk = produk['deskripsi'] ?? '-';
    int stokProduk = int.tryParse(produk['stok']?.toString() ?? '0') ?? 0;
    String gambarProduk = produk['gambar'] ?? 'default.jpg';

    bool isHabis = stokProduk <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _tampilkanDetailProduk(context, controller, produk),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    '${ApiConfig.baseUrl}/images/$gambarProduk',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaProduk,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.brown),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(deskripsiProduk,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(controller.formatRupiah(hargaProduk),
                          style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      Text('Stok: $stokProduk',
                          style: TextStyle(
                              color: isHabis ? Colors.red : Colors.black54,
                              fontSize: 11,
                              fontWeight: isHabis
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => controller.userRole.value == 'admin'
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.zero),
                                onPressed: () async {
                                  final result = await Get.to(
                                      () => EditProduk(produk: produk));
                                  if (result == true) {
                                    controller.fetchProduk();
                                  }
                                },
                                child: const Text('Edit',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.zero),
                                onPressed: () => _konfirmasiHapus(
                                    context,
                                    controller,
                                    produk['id'].toString(),
                                    namaProduk),
                                child: const Text('Hapus',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: isHabis
                                ? null
                                : () => controller.tambahKeKeranjang(produk),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isHabis ? Colors.grey : Colors.orange[600],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              isHabis ? 'Stok Habis' : 'Tambah',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
