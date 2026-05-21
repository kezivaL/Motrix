import '../models/rule.dart';
import '../models/kerusakan.dart';

class DiagnoseEngine {
  static List<Map<String, dynamic>> prosesDiagnosa({
    required dynamic gejalaDipilih,
    Map<String, double>? gejalaCfUser,
    required List<Rule> rules,
    required List<Kerusakan> kerusakanList,
  }) {
    final Map<String, double> gejalaUser = {};

    if (gejalaCfUser != null) {
      gejalaUser.addAll(gejalaCfUser);
    } else if (gejalaDipilih is Map<String, double>) {
      gejalaUser.addAll(gejalaDipilih);
    } else if (gejalaDipilih is Map) {
      gejalaDipilih.forEach((key, value) {
        gejalaUser[key.toString()] = (value as num).toDouble();
      });
    } else if (gejalaDipilih is List<String>) {
      for (final id in gejalaDipilih) {
        gejalaUser[id] = 1.0;
      }
    }

    final List<Map<String, dynamic>> hasil = [];

    for (final rule in rules) {
      double cfCombine = 0.0;
      bool hasMatchedGejala = false;

      for (final rg in rule.gejalaRules) {
        if (!gejalaUser.containsKey(rg.gejalaId)) continue;

        final double cfUser = gejalaUser[rg.gejalaId]!;
        final double cfPakar = rg.bobotPakar;
        final double cfGejala = cfUser * cfPakar;

        if (!hasMatchedGejala) {
          cfCombine = cfGejala;
          hasMatchedGejala = true;
        } else {
          cfCombine = cfCombine + cfGejala * (1 - cfCombine);
        }
      }

      if (!hasMatchedGejala || cfCombine <= 0) continue;

      final kerusakan = kerusakanList.firstWhere(
        (k) => k.id == rule.kerusakanId,
      );

      hasil.add({
        "id": kerusakan.id,
        "nama": kerusakan.nama,
        "deskripsi": kerusakan.deskripsi.join(", "),
        "solusi": kerusakan.solusi,
        "skor": cfCombine.clamp(0.0, 1.0),
        "persentase": (cfCombine.clamp(0.0, 1.0) * 100).toStringAsFixed(2),
      });
    }

    hasil.sort((a, b) {
      final skorA = (a["skor"] ?? 0).toDouble();
      final skorB = (b["skor"] ?? 0).toDouble();
      return skorB.compareTo(skorA);
    });

    return hasil;
  }
}