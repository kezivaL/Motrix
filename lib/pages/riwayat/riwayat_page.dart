import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/diagnosa.dart';
import '../../data/kerusakan_data.dart';
import 'detail_riwayat_page.dart';

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

  Future<void> loadData() async {
    final data = await StorageService.loadRiwayat();

    setState(() {
      riwayat = data.reversed.toList();
    });
  }

  String getNamaKerusakan(String id) {
    try {
      final k = dataKerusakan.firstWhere((e) => e.id == id);
      return k.nama;
    } catch (_) {
      return "Kerusakan tidak ditemukan";
    }
  }

  Color getScoreColor(double skor) {
    if (skor >= 0.7) return const Color(0xFFEF4444);
    if (skor >= 0.4) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }

  String formatTanggal(DateTime tanggal) {
    return "${tanggal.day}/${tanggal.month}/${tanggal.year} • ${tanggal.hour}:${tanggal.minute.toString().padLeft(2, '0')}";
  }

  List<Map<String, dynamic>> buildResults(Diagnosa item) {
    final sortedHasil = List<HasilDiagnosa>.from(item.hasil)
      ..sort((a, b) => b.skor.compareTo(a.skor));

    return sortedHasil.map((h) {
      final k = dataKerusakan.firstWhere(
        (e) => e.id == h.kerusakanId,
      );

      return {
        "id": k.id,
        "nama": k.nama,
        "deskripsi": k.deskripsi.join(", "),
        "solusi": k.solusi,
        "skor": h.skor,
      };
    }).toList();
  }

  void hapusSemua() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Semua Riwayat"),
        content: const Text("Yakin ingin menghapus semua riwayat diagnosa?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearRiwayat();
              await loadData();

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void hapusItem(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Riwayat"),
        content: const Text("Yakin ingin menghapus riwayat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              riwayat.removeAt(index);
              await StorageService.saveRiwayat(riwayat.reversed.toList());
              await loadData();

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 18,
              20,
              26,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 3, right: 14, bottom: 8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Riwayat Diagnosa",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${riwayat.length} riwayat diagnosa tersimpan",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: riwayat.isEmpty ? null : hapusSemua,
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: riwayat.isEmpty ? Colors.white38 : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: riwayat.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada riwayat diagnosa",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: riwayat.length,
                    itemBuilder: (context, index) {
                      final item = riwayat[index];

                      final sortedHasil = List<HasilDiagnosa>.from(item.hasil)
                        ..sort((a, b) => b.skor.compareTo(a.skor));

                      if (sortedHasil.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final main = sortedHasil.first;
                      final skor = main.skor;
                      final persen = (skor * 100).round();
                      final color = getScoreColor(skor);

                      return InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailRiwayatPage(
                                tanggal: item.tanggal,
                                results: buildResults(item),
                                totalGejala: item.gejalaTerpilih.isEmpty
                                    ? item.hasil.length
                                    : item.gejalaTerpilih.length,
                                gejalaTerpilih: item.gejalaTerpilih
                                    .map((e) => e.toMap())
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  Icons.analytics_rounded,
                                  color: color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatTanggal(item.tanggal),
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      getNamaKerusakan(main.kerusakanId),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "$persen%",
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${item.hasil.length} kemungkinan",
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => hapusItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}