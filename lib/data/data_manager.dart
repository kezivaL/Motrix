import '../models/kerusakan.dart';
import '../models/symptom.dart';
import '../models/rule.dart';
import '../models/diagnosa.dart';

import '../services/storage_service.dart';

import 'kerusakan_data.dart';
import 'symptom_data.dart';
import 'rule_data.dart';

class DataManager {
  static List<Kerusakan> kerusakan = [];
  static List<Symptom> gejala = [];
  static List<Rule> rules = [];
  static List<Diagnosa> riwayat = [];

  static Future<void> loadAll() async {
    await loadMasterData();
    await loadRiwayat();
  }

  static Future<void> loadMasterData() async {
    gejala = await StorageService.loadGejalaLocal();
    kerusakan = await StorageService.loadKerusakanLocal();
    rules = await StorageService.loadRuleLocal();

    if (gejala.isEmpty) {
      gejala = List<Symptom>.from(dataSymptom);
      await StorageService.saveGejalaLocalOnly(gejala);
    }

    if (kerusakan.isEmpty) {
      kerusakan = List<Kerusakan>.from(dataKerusakan);
      await StorageService.saveKerusakanLocalOnly(kerusakan);
    }

    if (rules.isEmpty) {
      rules = List<Rule>.from(dataRule);
      await StorageService.saveRuleLocalOnly(rules);
    }
  }

  static Future<void> loadRiwayat() async {
    riwayat = await StorageService.loadRiwayat();
  }

  static Future<void> refreshFromSupabase({bool includeRiwayat = false}) async {
    final latestGejala = await StorageService.loadGejalaFromSupabase();
    final latestKerusakan = await StorageService.loadKerusakanFromSupabase();
    final latestRules = await StorageService.loadRuleFromSupabase();

    gejala = latestGejala;
    kerusakan = latestKerusakan;
    rules = latestRules;

    if (includeRiwayat) {
      riwayat = await StorageService.loadRiwayatFromSupabase();
    }
  }

  static Future<void> saveGejala(List<Symptom> data) async {
    gejala = List<Symptom>.from(data);
    await StorageService.saveGejala(gejala);
  }

  static Future<void> saveKerusakan(List<Kerusakan> data) async {
    kerusakan = List<Kerusakan>.from(data);
    await StorageService.saveKerusakan(kerusakan);
  }

  static Future<void> saveRules(List<Rule> data) async {
    rules = List<Rule>.from(data);
    await StorageService.saveRule(rules);
  }

  static Future<void> saveRiwayat(List<Diagnosa> data) async {
    riwayat = List<Diagnosa>.from(data);
    await StorageService.saveRiwayat(riwayat);
  }

  static Future<void> tambahRiwayat(Diagnosa data) async {
    await StorageService.tambahRiwayat(data);
    riwayat = await StorageService.loadRiwayat();
  }

  static Future<void> clearRiwayat() async {
    await StorageService.clearRiwayat();
    riwayat.clear();
  }
}