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

List<Symptom> get gejala {
  final list = [...DataManager.gejala];

  const urutanKategori = {
    "Mesin": 1,
    "Kelistrikan": 2,
    "Transmisi": 3,
    "Rem": 4,
  };

  list.sort((a, b) {
    final ka = urutanKategori[a.kategori] ?? 99;
    final kb = urutanKategori[b.kategori] ?? 99;
    return ka.compareTo(kb);
  });

  return list;
}

  final Set<int> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diagnosa")),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gejala.length,
        itemBuilder: (context, index) {
          final item = gejala[index];
          final isChecked = selected.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                isChecked ? selected.remove(index) : selected.add(index);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isChecked ? Colors.blue : Colors.grey.shade300,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isChecked ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      color: isChecked ? Colors.blue : Colors.transparent,
                    ),
                    child: isChecked
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 FIX
                        Text(item.nama,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),

                        // 🔥 FIX
                        buildBadge(item.kategori),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selected.isEmpty
              ? null
              : () async {
                  // 🔥 FIX (PAKAI OBJECT)
                  List<String> gejalaDipilih = selected
                      .map((i) => gejala[i].id)
                      .toList();

                  final hasil = DiagnoseEngine.prosesDiagnosa(
                    gejalaDipilih: gejalaDipilih,
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
                );

                await StorageService.tambahRiwayat(diagnosa);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultPage(
                        results: hasil,
                        totalGejala: selected.length,
                      ),
                    ),
                  );
                },
          child: const Text("Proses Diagnosa"),
        ),
      ),
    );
  }

  Widget buildBadge(String kategori) {
    Color bg;
    Color text;

    switch (kategori) {
      case "Mesin":
        bg = Colors.red.withOpacity(0.1);
        text = Colors.red;
        break;
      case "Kelistrikan":
        bg = Colors.yellow.withOpacity(0.2);
        text = Colors.orange;
        break;
      case "Penggerak":
        bg = Colors.blue.withOpacity(0.1);
        text = Colors.blue;
        break;
      case "Rem":
        bg = Colors.orange.withOpacity(0.15);
        text = Colors.orange;
        break;
      default:
        bg = Colors.grey.withOpacity(0.1);
        text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        kategori,
        style: TextStyle(fontSize: 12, color: text),
      ),
    );
  }
}