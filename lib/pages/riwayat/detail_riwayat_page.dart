import 'package:flutter/material.dart';

class DetailRiwayatPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailRiwayatPage({
    super.key,
    required this.data,
  });

  String formatTime() {
    return "${data["tanggal"]} • ${data["jam"]}";
  }

  @override
  Widget build(BuildContext context) {
    final results = data["results"] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Riwayat")),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "${results.length} hasil diagnosa",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];

                final solusi = item["solusi"] ?? [];
                final deskripsi = item["deskripsi"] ?? "-";
                final persen = item["persen"] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item["nama"] ?? "-",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tingkat kemungkinan"),
                          Text("$persen%"),
                        ],
                      ),

                      const SizedBox(height: 6),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: persen / 100,
                          minHeight: 10,
                          color: Colors.blue,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Deskripsi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deskripsi,
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Saran Perbaikan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      ...List.generate(
                        solusi.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text("${i + 1}. ${solusi[i]}"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
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
    );
  }
}