import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text(
          "Hakkımızda",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Not Özetleyici Uygulaması",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Bu uygulama, kullanıcıların yazdığı uzun notları yapay zeka yardımıyla analiz ederek kısa bir özet ve başlık oluşturur. "
              "Veriler Firebase Firestore’da saklanır, özetleme Flask tabanlı özel bir API ile yapılır.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              "🛠 Kullanılan Teknolojiler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("• Flutter (mobil uygulama)"),
            const Text("• Firebase Auth ve Firestore"),
            const Text("• Flask (REST API ile özetleme)"),
            const SizedBox(height: 24),
            const Text(
              "👤 Geliştiriciler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Muhammed Acarca ve Emre Kazancı",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Center(
              child: Image.asset(
                "assets/images/spl.png", // ❗ Uygulama ikonu buraya
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text("Tüm hakları saklıdır © 2025")),
          ],
        ),
      ),
    );
  }
}
