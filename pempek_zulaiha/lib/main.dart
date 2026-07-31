import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart'; // Pastikan path ini benar

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pempek Zulaiha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Jadikan SplashScreen sebagai halaman pertama kali dibuka
      home: const SplashScreen(),
    );
  }
}
