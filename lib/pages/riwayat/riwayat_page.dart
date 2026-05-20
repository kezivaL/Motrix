import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/diagnosa.dart';
import '../../data/kerusakan_data.dart';
import '../diagnose/result_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Diagnosa> riwayat = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await StorageService.loadRiwayat();
    setState(() {
      riwayat = data.reversed.toList();
    });
  }

  // 🔥 mapping ID → nama
  String getNama(String id) {
    final k = dataKerusakan.firstWhere(
      (e) => e.id == id,
      orElse: () => dataKerusakan.first,
    );
    return k.nama;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Diagnosa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: riwayat.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Semua"),
                        content: const Text(
                            "Yakin ingin menghapus semua riwayat?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await StorageService.clearRiwayat();
                              loadData();
                              Navigator.pop(context);
                            },
                            child: const Text("Hapus"),
                          ),
                        ],
                      ),
                    );
                  },
          )
        ],
      ),

      body: riwayat.isEmpty
          ? const Center(child: Text("Belum ada riwayat diagnosa"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: riwayat.length,
              itemBuilder: (context, index) {
                final item = riwayat[index];

                // 🔥 ambil hasil utama (skor tertinggi)
                item.hasil.sort((a, b) => b.skor.compareTo(a.skor));
                final main = item.hasil.first;

                final skor = main.skor;
                final persen = (skor * 100).toInt();

                // 🔥 warna indikator
                Color color;
                if (skor >= 0.7) {
                  color = Colors.red;
                } else if (skor >= 0.4) {
                  color = Colors.orange;
                } else {
                  color = Colors.green;
                }

                final tanggal = item.tanggal;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: color),

                      const SizedBox(width: 12),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultPage(
                                  results: item.hasil.map((h) {
                                    final k = dataKerusakan.firstWhere(
                                      (e) => e.id == h.kerusakanId,
                                    );

                                    return {
                                      "id": k.id,
                                      "nama": k.nama,
                                      "deskripsi":
                                          k.deskripsi.join(", "),
                                      "solusi": k.solusi,
                                      "skor": h.skor,
                                    };
                                  }).toList(),
                                  totalGejala: item.hasil.length,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${tanggal.day}/${tanggal.month}/${tanggal.year} • ${tanggal.hour}:${tanggal.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  "${getNama(main.kerusakanId)} ($persen%)"),
                              Text(
                                "${item.hasil.length} kemungkinan kerusakan",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 🔥 DELETE PER ITEM
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Hapus Riwayat"),
                              content: const Text(
                                  "Yakin ingin menghapus data ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    riwayat.removeAt(index);
                                    await StorageService
                                        .saveRiwayat(riwayat);
                                    loadData();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}