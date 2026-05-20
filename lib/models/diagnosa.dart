class Diagnosa {
  final DateTime tanggal;
  final List<HasilDiagnosa> hasil;

  Diagnosa({
    required this.tanggal,
    required this.hasil,
  });

  // 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String(),
      'hasil': hasil.map((e) => e.toJson()).toList(),
    };
  }

  // 🔥 FROM JSON
  factory Diagnosa.fromJson(Map<String, dynamic> json) {
    return Diagnosa(
      tanggal: DateTime.parse(json['tanggal'] ?? DateTime.now().toString()),
      hasil: (json['hasil'] as List<dynamic>? ?? [])
          .map((e) => HasilDiagnosa.fromJson(e))
          .toList(),
    );
  }
}

class HasilDiagnosa {
  final String kerusakanId;
  final double skor;

  HasilDiagnosa({
    required this.kerusakanId,
    required this.skor,
  });

  // 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'kerusakanId': kerusakanId,
      'skor': skor,
    };
  }

  // 🔥 FROM JSON
  factory HasilDiagnosa.fromJson(Map<String, dynamic> json) {
    return HasilDiagnosa(
      kerusakanId: json['kerusakanId'] ?? '',
      skor: (json['skor'] ?? 0).toDouble(),
    );
  }
}
