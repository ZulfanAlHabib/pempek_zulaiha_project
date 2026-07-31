import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({Key? key}) : super(key: key);

  void _showEditProfileDialog(ProfilController controller) {
    // Isi data awal ke dalam textfield sebelum dialog terbuka
    controller.nameController.text = controller.namaUser.value;
    controller.emailController.text = controller.emailUser.value;
    controller.passwordController.clear(); // Kosongkan password

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Profil & Akun",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                    labelText: "Nama Lengkap", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru",
                  hintText: "Kosongkan jika tidak diganti",
                  hintStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: () => Get.back(),
                  child:
                      const Text("Batal", style: TextStyle(color: Colors.grey)),
                )),
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: controller.updateProfil,
                  child: const Text("Simpan",
                      style: TextStyle(color: Colors.white)),
                )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Pempek Zulaiha Mobile",
      applicationVersion: "1.0.0",
      applicationIcon:
          const Icon(Icons.restaurant_menu, size: 40, color: Colors.orange),
      children: const [
        SizedBox(height: 10),
        Text(
            "Aplikasi pemesanan pempek online khas Palembang tercepat, terlezat, dan terpercaya."),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfilController());

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Profil Saya',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orangeAccent,
                        child:
                            Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            Get.snackbar(
                                'Info', 'Fitur ubah foto sedang dikembangkan.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.brown, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                        controller.namaUser.value,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.emailUser.value,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
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
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.orange),
                    title: const Text('Edit Profil & Password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showEditProfileDialog(controller),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text('Tentang Aplikasi'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.support_agent, color: Colors.green),
                    title: const Text('Bantuan & CS WhatsApp'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.hubungiAdmin,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Keluar (Logout)',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: controller.logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
