import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _key = 'motrix_session_id';

  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final sessionId = _generateSessionId();
    await prefs.setString(_key, sessionId);

    return sessionId;
  }

  static String _generateSessionId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final randomText = List.generate(
      12,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();

    return 'mx_${timestamp}_$randomText';
  }
}