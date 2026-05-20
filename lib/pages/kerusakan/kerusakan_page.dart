import 'package:flutter/material.dart';
import '../../data/kerusakan_data.dart';
import '../../models/kerusakan.dart';
import 'detail_kerusakan_page.dart';

class KerusakanPage extends StatelessWidget {
  const KerusakanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 ambil data dari admin
    final List<Kerusakan> kerusakanList = List.from(dataKerusakan);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Kerusakan"),
      ),
      body: kerusakanList.isEmpty
          ? const Center(child: Text("Belum ada data kerusakan"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kerusakanList.length,
              itemBuilder: (context, index) {
                final item = kerusakanList[index];

                final icon = getKategoriIcon(item.kategori);
                final color = getKategoriColor(item.kategori);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailKerusakanPage(data: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 🔥 ICON
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color),
                        ),

                        const SizedBox(width: 12),

                        // 🔥 TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                item.kategori,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 🔥 ICON
  IconData getKategoriIcon(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Icons.build;
      case "Kelistrikan":
        return Icons.bolt;
      case "Penggerak":
      case "Transmisi":
        return Icons.settings;
      case "Rem":
        return Icons.warning;
      default:
        return Icons.device_unknown;
    }
  }

  // 🔥 WARNA
  Color getKategoriColor(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Colors.red;
      case "Kelistrikan":
        return Colors.amber;
      case "Penggerak":
      case "Transmisi":
        return Colors.blue;
      case "Rem":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}