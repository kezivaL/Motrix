import 'package:flutter/material.dart';
import '../../models/kerusakan.dart';

class DetailKerusakanPage extends StatelessWidget {
  final Kerusakan data;

  const DetailKerusakanPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    Color headerColor = getKategoriColor(data.kategori);
    IconData icon = getKategoriIcon(data.kategori);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Kerusakan"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔥 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 50, color: headerColor),

                  const SizedBox(height: 10),

                  Text(
                    data.nama,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    data.kategori,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// 📄 CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔥 DESKRIPSI (SUDAH BENAR)
                  buildSection("Deskripsi", data.deskripsi),

                  /// 🔥 SOLUSI (FIX ENTER → LIST)
                  buildSectionNumbered(
                    "Solusi",
                    data.solusi
                        .split('\n')
                        .where((e) => e.trim().isNotEmpty)
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 ICON
  IconData getKategoriIcon(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Icons.build;
      case "Kelistrikan":
        return Icons.bolt;
      case "Transmisi":
        return Icons.settings;
      case "Rem":
        return Icons.warning;
      default:
        return Icons.device_unknown;
    }
  }

  /// 🔥 WARNA
  Color getKategoriColor(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Colors.red;
      case "Kelistrikan":
        return Colors.amber;
      case "Transmisi":
        return Colors.blue;
      case "Rem":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// 🔹 SECTION BULLET (DESKRIPSI)
  Widget buildSection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🔥 SECTION NOMOR (SOLUSI)
  Widget buildSectionNumbered(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ...items.asMap().entries.map(
            (entry) {
              int i = entry.key + 1;
              String item = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$i. "),
                    Expanded(child: Text(item)),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}