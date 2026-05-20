class RiwayatData {
  static List<Map<String, dynamic>> riwayatList = [];

  static void tambahRiwayat(List<Map<String, dynamic>> hasil) {
    riwayatList.insert(0, { // 🔥 terbaru di atas
      "tanggal": DateTime.now(),
      "hasil": hasil,
    });
  }
    static void hapusRiwayat(int index) {
    if (index >= 0 && index < riwayatList.length) {
      riwayatList.removeAt(index);
    }
  }
  static void clearRiwayat() {
    riwayatList.clear();
  }
}