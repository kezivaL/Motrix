import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/symptom.dart';
import '../models/kerusakan.dart';
import '../models/rule.dart';
import '../models/diagnosa.dart';
import 'session_service.dart';

class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const Duration _supabaseTimeout = Duration(seconds: 6);

  // ================= HELPER =================

  static double _toDouble(dynamic value, {double fallback = 0.8}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static Future<void> _setLocal(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<List<dynamic>> _getLocalList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded;

    return [];
  }

  // ================= GEJALA =================

  static Future<void> saveGejalaLocalOnly(List<Symptom> data) async {
    await _setLocal('gejala', data.map((e) => e.toJson()).toList());
  }

  static Future<void> saveGejala(List<Symptom> data) async {
    final jsonData = data.map((e) => e.toJson()).toList();

    await saveGejalaLocalOnly(data);

    try {
      await _supabase.from('gejala').upsert(jsonData).timeout(_supabaseTimeout);
    } catch (_) {}
  }

  static Future<List<Symptom>> loadGejala() async {
    final local = await loadGejalaLocal();
    if (local.isNotEmpty) return local;

    return loadGejalaFromSupabase();
  }

  static Future<List<Symptom>> loadGejalaLocal() async {
    try {
      final decoded = await _getLocalList('gejala');

      return decoded.map<Symptom>((e) {
        return Symptom.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Symptom>> loadGejalaFromSupabase() async {
    try {
      final response = await _supabase
          .from('gejala')
          .select()
          .order('kategori', ascending: true)
          .order('nama', ascending: true)
          .timeout(_supabaseTimeout);

      final data = response.map<Symptom>((e) {
        return Symptom.fromJson(Map<String, dynamic>.from(e));
      }).toList();

      if (data.isNotEmpty) {
        await saveGejalaLocalOnly(data);
      }

      return data;
    } catch (_) {
      return loadGejalaLocal();
    }
  }

  // ================= KERUSAKAN =================

  static Future<void> saveKerusakanLocalOnly(List<Kerusakan> data) async {
    await _setLocal('kerusakan', data.map((e) => e.toJson()).toList());
  }

  static Future<void> saveKerusakan(List<Kerusakan> data) async {
    final jsonData = data.map((e) => e.toJson()).toList();

    await saveKerusakanLocalOnly(data);

    try {
      await _supabase
          .from('kerusakan')
          .upsert(jsonData)
          .timeout(_supabaseTimeout);
    } catch (_) {}
  }

  static Future<List<Kerusakan>> loadKerusakan() async {
    final local = await loadKerusakanLocal();
    if (local.isNotEmpty) return local;

    return loadKerusakanFromSupabase();
  }

  static Future<List<Kerusakan>> loadKerusakanLocal() async {
    try {
      final decoded = await _getLocalList('kerusakan');

      return decoded.map<Kerusakan>((e) {
        return Kerusakan.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Kerusakan>> loadKerusakanFromSupabase() async {
    try {
      final response = await _supabase
          .from('kerusakan')
          .select()
          .order('kategori', ascending: true)
          .order('nama', ascending: true)
          .timeout(_supabaseTimeout);

      final data = response.map<Kerusakan>((e) {
        return Kerusakan.fromJson(Map<String, dynamic>.from(e));
      }).toList();

      if (data.isNotEmpty) {
        await saveKerusakanLocalOnly(data);
      }

      return data;
    } catch (_) {
      return loadKerusakanLocal();
    }
  }

  // ================= RULE =================

  static Future<void> saveRuleLocalOnly(List<Rule> data) async {
    await _setLocal('rule', data.map((e) => e.toJson()).toList());
  }

  static Future<void> saveRule(List<Rule> data) async {
    await saveRuleLocalOnly(data);

    try {
      await _supabase
          .from('rules')
          .delete()
          .neq('kerusakan_id', '')
          .timeout(_supabaseTimeout);

      final rows = <Map<String, dynamic>>[];

      for (final rule in data) {
        for (final gejala in rule.gejalaRules) {
          rows.add({
            'kerusakan_id': rule.kerusakanId,
            'gejala_id': gejala.gejalaId,
            'bobot_pakar': gejala.bobotPakar,
          });
        }
      }

      if (rows.isNotEmpty) {
        await _supabase.from('rules').insert(rows).timeout(_supabaseTimeout);
      }
    } catch (_) {}
  }

  static Future<List<Rule>> loadRule() async {
    final local = await loadRuleLocal();
    if (local.isNotEmpty) return local;

    return loadRuleFromSupabase();
  }

  static Future<List<Rule>> loadRuleLocal() async {
    try {
      final decoded = await _getLocalList('rule');

      return decoded.map<Rule>((e) {
        return Rule.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Rule>> loadRuleFromSupabase() async {
    try {
      final response = await _supabase
          .from('rules')
          .select()
          .order('kerusakan_id', ascending: true)
          .timeout(_supabaseTimeout);

      final grouped = <String, List<RuleGejala>>{};

      for (final item in response) {
        final row = Map<String, dynamic>.from(item);

        final kerusakanId = row['kerusakan_id']?.toString() ?? '';
        final gejalaId = row['gejala_id']?.toString() ?? '';
        final bobotPakar = _toDouble(row['bobot_pakar']);

        if (kerusakanId.isEmpty || gejalaId.isEmpty) continue;

        grouped.putIfAbsent(kerusakanId, () => []);
        grouped[kerusakanId]!.add(
          RuleGejala(
            gejalaId: gejalaId,
            bobotPakar: bobotPakar,
          ),
        );
      }

      final data = grouped.entries.map<Rule>((entry) {
        return Rule(
          kerusakanId: entry.key,
          gejalaRules: entry.value,
        );
      }).toList();

      if (data.isNotEmpty) {
        await saveRuleLocalOnly(data);
      }

      return data;
    } catch (_) {
      return loadRuleLocal();
    }
  }

  // ================= RIWAYAT =================

  static Future<void> saveRiwayat(List<Diagnosa> data) async {
    final sessionId = await SessionService.getSessionId();

    final localData = data.map<Diagnosa>((e) {
      return Diagnosa(
        id: e.id,
        sessionId: sessionId,
        tanggal: e.tanggal,
        hasil: e.hasil,
        gejalaTerpilih: e.gejalaTerpilih,
      );
    }).toList();

    await _setLocal('riwayat', localData.map((e) => e.toJson()).toList());

    try {
      await _supabase
          .from('riwayat_diagnosa')
          .delete()
          .eq('session_id', sessionId)
          .timeout(_supabaseTimeout);

      final rows = localData.map((e) {
        return {
          'session_id': sessionId,
          'tanggal': e.tanggal.toIso8601String(),
          'hasil': e.hasil.map((x) => x.toJson()).toList(),
          'gejala_terpilih': e.gejalaTerpilih.map((x) => x.toJson()).toList(),
        };
      }).toList();

      if (rows.isNotEmpty) {
        await _supabase
            .from('riwayat_diagnosa')
            .insert(rows)
            .timeout(_supabaseTimeout);
      }
    } catch (_) {}
  }

  static Future<List<Diagnosa>> loadRiwayat() async {
    final local = await loadRiwayatLocal();
    if (local.isNotEmpty) return local;

    return loadRiwayatFromSupabase();
  }

  static Future<List<Diagnosa>> loadRiwayatLocal() async {
    final sessionId = await SessionService.getSessionId();

    try {
      final decoded = await _getLocalList('riwayat');

      return decoded.map<Diagnosa>((e) {
        final item = Diagnosa.fromJson(Map<String, dynamic>.from(e));

        return Diagnosa(
          id: item.id,
          sessionId: item.sessionId ?? sessionId,
          tanggal: item.tanggal,
          hasil: item.hasil,
          gejalaTerpilih: item.gejalaTerpilih,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Diagnosa>> loadRiwayatFromSupabase() async {
    final sessionId = await SessionService.getSessionId();

    try {
      final response = await _supabase
          .from('riwayat_diagnosa')
          .select()
          .eq('session_id', sessionId)
          .order('tanggal', ascending: true)
          .timeout(_supabaseTimeout);

      final data = response.map<Diagnosa>((e) {
        final row = Map<String, dynamic>.from(e);

        return Diagnosa.fromJson({
          'id': row['id'],
          'sessionId': row['session_id'],
          'tanggal': row['tanggal'],
          'hasil': row['hasil'] ?? [],
          'gejalaTerpilih': row['gejala_terpilih'] ?? [],
        });
      }).toList();

      await _setLocal('riwayat', data.map((e) => e.toJson()).toList());

      return data;
    } catch (_) {
      return loadRiwayatLocal();
    }
  }

  // ================= TAMBAH RIWAYAT =================

  static Future<void> tambahRiwayat(Diagnosa data) async {
    final sessionId = await SessionService.getSessionId();

    final diagnosa = Diagnosa(
      id: data.id,
      sessionId: sessionId,
      tanggal: data.tanggal,
      hasil: data.hasil,
      gejalaTerpilih: data.gejalaTerpilih,
    );

    final list = await loadRiwayatLocal();
    list.add(diagnosa);

    await _setLocal('riwayat', list.map((e) => e.toJson()).toList());

    try {
      await _supabase
          .from('riwayat_diagnosa')
          .insert({
            'session_id': sessionId,
            'tanggal': diagnosa.tanggal.toIso8601String(),
            'hasil': diagnosa.hasil.map((e) => e.toJson()).toList(),
            'gejala_terpilih':
                diagnosa.gejalaTerpilih.map((e) => e.toJson()).toList(),
          })
          .timeout(_supabaseTimeout);
    } catch (_) {}
  }

  // ================= HAPUS SEMUA =================

  static Future<void> clearRiwayat() async {
    final sessionId = await SessionService.getSessionId();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('riwayat');

    try {
      await _supabase
          .from('riwayat_diagnosa')
          .delete()
          .eq('session_id', sessionId)
          .timeout(_supabaseTimeout);
    } catch (_) {}
  }
}