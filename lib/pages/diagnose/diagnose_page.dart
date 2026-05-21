import 'package:flutter/material.dart';
import 'result_page.dart';
import '../../data/rule_data.dart';
import '../../data/kerusakan_data.dart';
import '../../engine/diagnose_engine.dart';
import '../../data/data_manager.dart';
import '../../models/symptom.dart';
import '../../models/diagnosa.dart';
import '../../services/storage_service.dart';

class DiagnosePage extends StatefulWidget {
  const DiagnosePage({super.key});

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final Map<String, double> selectedCf = {};

  final List<String> urutanKategori = [
    "Mesin",
    "Kelistrikan",
    "Transmisi",
    "Penggerak",
    "Rem",
  ];

  final Map<String, double> pilihanKeyakinan = {
    "Tidak yakin": 0.4,
    "Cukup yakin": 0.6,
    "Yakin": 0.8,
    "Sangat yakin": 1.0,
  };

  List<Symptom> get gejala {
    final list = List<Symptom>.from(DataManager.gejala);

    list.sort((a, b) {
      final kategoriCompare =
          kategoriIndex(a.kategori).compareTo(kategoriIndex(b.kategori));

      if (kategoriCompare != 0) return kategoriCompare;

      return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
    });

    return list;
  }

  int kategoriIndex(String kategori) {
    final index = urutanKategori.indexOf(kategori);
    return index == -1 ? 999 : index;
  }

  Color kategoriColor(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Colors.redAccent;
      case "Kelistrikan":
        return Colors.amber;
      case "Transmisi":
        return Colors.lightBlue;
      case "Penggerak":
        return Colors.teal;
      case "Rem":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData kategoriIcon(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Icons.precision_manufacturing_rounded;
      case "Kelistrikan":
        return Icons.bolt_rounded;
      case "Transmisi":
        return Icons.settings_rounded;
      case "Penggerak":
        return Icons.cyclone_rounded;
      case "Rem":
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text("Diagnosa"),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: gejala.isEmpty
                ? const Center(child: Text("Belum ada data gejala"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: gejala.length,
                    itemBuilder: (context, index) {
                      final item = gejala[index];

                      final showHeader = index == 0 ||
                          gejala[index - 1].kategori != item.kategori;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) kategoriHeader(item.kategori),
                          buildGejalaCard(item),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: selectedCf.isEmpty ? null : prosesDiagnosa,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            selectedCf.isEmpty
                ? "Pilih Gejala Terlebih Dahulu"
                : "Proses Diagnosa (${selectedCf.length} gejala)",
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.fact_check_rounded, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCf.isEmpty
                    ? "Pilih gejala yang dialami motor"
                    : "${selectedCf.length} gejala dipilih",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              "CF User",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget kategoriHeader(String kategori) {
    final color = kategoriColor(kategori);

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Icon(kategoriIcon(kategori), color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            kategori,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGejalaCard(Symptom item) {
    final bool isChecked = selectedCf.containsKey(item.id);
    final double cfValue = selectedCf[item.id] ?? 0.8;
    final Color color = kategoriColor(item.kategori);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isChecked ? color.withOpacity(0.10) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isChecked ? color : Colors.grey.shade200,
          width: isChecked ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                if (isChecked) {
                  selectedCf.remove(item.id);
                } else {
                  selectedCf[item.id] = 0.8;
                }
              });
            },
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked ? color : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? color : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(
                    kategoriIcon(item.kategori),
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildBadge(item.kategori),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isChecked) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  "Tingkat keyakinan",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  cfValue.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pilihanKeyakinan.entries.map((entry) {
                  final bool aktif = cfValue == entry.value;

                  return ChoiceChip(
                    selected: aktif,
                    label: Text(entry.key),
                    selectedColor: color.withOpacity(0.18),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                      color: aktif ? color : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: aktif ? color : const Color(0xFF475569),
                      fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCf[item.id] = entry.value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildBadge(String kategori) {
    final color = kategoriColor(kategori);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kategori,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> prosesDiagnosa() async {
    final Map<String, double> gejalaCfUser = Map<String, double>.from(selectedCf);

    final hasil = DiagnoseEngine.prosesDiagnosa(
      gejalaDipilih: gejalaCfUser.keys.toList(),
      gejalaCfUser: gejalaCfUser,
      rules: dataRule,
      kerusakanList: dataKerusakan,
    );

final diagnosa = Diagnosa(
  tanggal: DateTime.now(),
  hasil: hasil.map((e) {
    return HasilDiagnosa(
      kerusakanId: e["id"],
      skor: (e["skor"] ?? 0).toDouble(),
    );
  }).toList(),
  gejalaTerpilih: selectedCf.entries.map((entry) {
    final g = gejala.firstWhere((item) => item.id == entry.key);

    return GejalaTerpilihDiagnosa(
      gejalaId: g.id,
      nama: g.nama,
      kategori: g.kategori,
      cfUser: entry.value,
    );
  }).toList(),
);

    await StorageService.tambahRiwayat(diagnosa);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
  results: hasil,
  totalGejala: selectedCf.length,

  gejalaTerpilih: selectedCf.entries.map((entry) {
    final g = gejala.firstWhere(
      (item) => item.id == entry.key,
    );

    return {
      "id": g.id,
      "nama": g.nama,
      "kategori": g.kategori,
      "cfUser": entry.value,
    };
  }).toList(),
),
      ),
    );
  }
}