class Diagnosa {
  final String? id;
  final String? sessionId;
  final DateTime tanggal;
  final List<HasilDiagnosa> hasil;
  final List<GejalaTerpilihDiagnosa> gejalaTerpilih;

  Diagnosa({
    this.id,
    this.sessionId,
    required this.tanggal,
    required this.hasil,
    this.gejalaTerpilih = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'tanggal': tanggal.toIso8601String(),
      'hasil': hasil.map((e) => e.toJson()).toList(),
      'gejalaTerpilih': gejalaTerpilih.map((e) => e.toJson()).toList(),
    };
  }

  factory Diagnosa.fromJson(Map<String, dynamic> json) {
    return Diagnosa(
      id: json['id']?.toString(),
      sessionId: json['sessionId']?.toString() ?? json['session_id']?.toString(),
      tanggal: DateTime.parse(json['tanggal'] ?? DateTime.now().toString()),
      hasil: (json['hasil'] as List<dynamic>? ?? [])
          .map((e) => HasilDiagnosa.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      gejalaTerpilih: ((json['gejalaTerpilih'] ?? json['gejala_terpilih'])
                  as List<dynamic>? ??
              [])
          .map(
            (e) => GejalaTerpilihDiagnosa.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
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

  Map<String, dynamic> toJson() {
    return {
      'kerusakanId': kerusakanId,
      'skor': skor,
    };
  }

  factory HasilDiagnosa.fromJson(Map<String, dynamic> json) {
    return HasilDiagnosa(
      kerusakanId: json['kerusakanId'] ?? json['kerusakan_id'] ?? '',
      skor: (json['skor'] ?? 0).toDouble(),
    );
  }
}

class GejalaTerpilihDiagnosa {
  final String gejalaId;
  final String nama;
  final String kategori;
  final double cfUser;

  GejalaTerpilihDiagnosa({
    required this.gejalaId,
    required this.nama,
    required this.kategori,
    required this.cfUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'gejalaId': gejalaId,
      'nama': nama,
      'kategori': kategori,
      'cfUser': cfUser,
    };
  }

  factory GejalaTerpilihDiagnosa.fromJson(Map<String, dynamic> json) {
    return GejalaTerpilihDiagnosa(
      gejalaId: json['gejalaId'] ?? json['gejala_id'] ?? '',
      nama: json['nama'] ?? '-',
      kategori: json['kategori'] ?? '-',
      cfUser: (json['cfUser'] ?? json['cf_user'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': gejalaId,
      'nama': nama,
      'kategori': kategori,
      'cfUser': cfUser,
    };
  }
}