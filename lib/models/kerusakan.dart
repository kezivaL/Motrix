class Kerusakan {
  final String id;
  final String nama;
  final String kategori;
  final String solusi;
  final List<String> deskripsi; // 🔥 FIX DI SINI

  Kerusakan({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.solusi,
    required this.deskripsi,
  });

  // 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'solusi': solusi,
      'deskripsi': deskripsi,
    };
  }

  // 🔥 FROM JSON
factory Kerusakan.fromJson(Map<String, dynamic> json) {
  return Kerusakan(
    id: json['id'],
    nama: json['nama'],
    kategori: json['kategori'],

    // 🔥 SOLUSI (AMAN)
    solusi: json['solusi'] is List
        ? (json['solusi'] as List).join(", ")
        : json['solusi'] ?? "",

    // 🔥 DESKRIPSI (INI YANG FIX BUG KAMU)
    deskripsi: json['deskripsi'] is List
        ? List<String>.from(json['deskripsi'])
        : [json['deskripsi'] ?? ""],
  );
}
}