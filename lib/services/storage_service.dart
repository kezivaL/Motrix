import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/symptom.dart';
import '../models/kerusakan.dart';
import '../models/rule.dart';
import '../models/diagnosa.dart';

class StorageService {

  // ================= GEJALA =================
  static Future<void> saveGejala(List<Symptom> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = data.map((e) => e.toJson()).toList();
    await prefs.setString('gejala', jsonEncode(jsonData));
  }

  static Future<List<Symptom>> loadGejala() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('gejala');

    if (data == null) return [];

    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => Symptom.fromJson(e)).toList();
  }

  // ================= KERUSAKAN =================
  static Future<void> saveKerusakan(List<Kerusakan> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = data.map((e) => e.toJson()).toList();
    await prefs.setString('kerusakan', jsonEncode(jsonData));
  }

  static Future<List<Kerusakan>> loadKerusakan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('kerusakan');

    if (data == null) return [];

    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => Kerusakan.fromJson(e)).toList();
  }

  // ================= RULE =================
  static Future<void> saveRule(List<Rule> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = data.map((e) => e.toJson()).toList();
    await prefs.setString('rule', jsonEncode(jsonData));
  }

  static Future<List<Rule>> loadRule() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('rule');

    if (data == null) return [];

    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => Rule.fromJson(e)).toList();
  }

  // ================= RIWAYAT =================
  static Future<void> saveRiwayat(List<Diagnosa> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = data.map((e) => e.toJson()).toList();
    await prefs.setString('riwayat', jsonEncode(jsonData));
  }

  static Future<List<Diagnosa>> loadRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('riwayat');

    if (data == null) return [];

    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => Diagnosa.fromJson(e)).toList();
  }
    // ================= TAMBAH RIWAYAT =================
  static Future<void> tambahRiwayat(Diagnosa data) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString('riwayat');

    List<Diagnosa> list = [];

    if (existing != null) {
      final decoded = jsonDecode(existing) as List;
      list = decoded.map((e) => Diagnosa.fromJson(e)).toList();
    }

    list.add(data);

    final jsonData = list.map((e) => e.toJson()).toList();
    await prefs.setString('riwayat', jsonEncode(jsonData));
  }

  // ================= HAPUS SEMUA =================
  static Future<void> clearRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('riwayat');
  }
}