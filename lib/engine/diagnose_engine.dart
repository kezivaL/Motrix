import '../models/rule.dart';
import '../models/kerusakan.dart';

class DiagnoseEngine {
  static List<Map<String, dynamic>> prosesDiagnosa({
    required List<String> gejalaDipilih,
    required List<Rule> rules,
    required List<Kerusakan> kerusakanList,
  }) {
    List<Map<String, dynamic>> hasil = [];

    for (var rule in rules) {
      final gejalaRule = rule.gejalaIds;

      int cocok = gejalaDipilih
          .where((g) => gejalaRule.contains(g))
          .length;

      if (gejalaRule.isEmpty) continue;

      double skor = cocok / gejalaRule.length;

      final kerusakan = kerusakanList
          .firstWhere((k) => k.id == rule.kerusakanId);

      hasil.add({
        "id": kerusakan.id,
        "nama": kerusakan.nama,

        // 🔥 FIX UTAMA
        "deskripsi": kerusakan.deskripsi.join(", "),

        "solusi": kerusakan.solusi,

        "skor": skor,
      });
    }

    hasil = hasil.where((h) => h["skor"] > 0).toList();

    hasil.sort((a, b) => b["skor"].compareTo(a["skor"]));

    return hasil;
  }
}