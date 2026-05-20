class Symptom {
  final String id;
  final String nama;
  final String kategori;

  Symptom({
    required this.id,
    required this.nama,
    required this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      nama: json['nama'],
      kategori: json['kategori'],
    );
  }
}