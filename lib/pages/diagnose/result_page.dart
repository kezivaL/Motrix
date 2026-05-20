import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final int totalGejala;

  const ResultPage({
    super.key,
    required this.results,
    required this.totalGejala,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Diagnosa")),
      body: Column(
        children: [
          // 🔵 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${now.day} ${_bulan(now.month)} ${now.year} • ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "$totalGejala gejala dipilih",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // 📊 LIST HASIL
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];

                final double skor = (item["skor"] ?? 0).toDouble();
                final String solusi = item["solusi"] ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔢 RANKING
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "#${index + 1}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item["nama"] ?? "-",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text("Tingkat kemungkinan"),
                      const SizedBox(height: 6),

                      /// 🔥 PROGRESS BAR
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: skor,
                          minHeight: 8,
                          color: Colors.blue,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("${(skor * 100).toInt()}%"),

                      const SizedBox(height: 14),

                      /// 🔥 DESKRIPSI
                      const Text(
                        "Deskripsi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(item["deskripsi"] ?? "-"),

                      const SizedBox(height: 14),

                      /// 🔥 SOLUSI (FIX ENTER → LIST NOMOR)
                      const Text(
                        "Saran Perbaikan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: solusi
                            .split('\n')
                            .where((e) => e.trim().isNotEmpty)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          int i = entry.key + 1;
                          String s = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("$i. "),
                                Expanded(child: Text(s)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// 🖨️ BUTTON CETAK
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print),
              label: const Text("Cetak"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 HELPER BULAN
  String _bulan(int bulan) {
    const namaBulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return namaBulan[bulan - 1];
  }
}