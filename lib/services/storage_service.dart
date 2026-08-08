import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class StorageService {
  static const _kHistory = 'session_history';
  static const _kAccentColor = 'accent_color';
  static const _kThemeMode = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const _kLastDuration = 'last_duration';
  static const _kLastLevel = 'last_level';
  static const _kLastFocus = 'last_focus';
  static const _kVoiceEnabled = 'voice_enabled';
  static const _kMusicEnabled = 'music_enabled';
  static const _kGithubToken = 'github_token';
  static const _kGithubRepo = 'github_repo'; // owner/repo
  static const _kAutoBackup = 'auto_backup';
  static const _kTotalMinutes = 'total_minutes';
  static const _kTotalSessions = 'total_sessions';
  static const _kFavorites = 'favorite_sessions';
  static const _kLastSessionDate = 'last_session_date';

  static Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // ---- Theme ----
  static Future<void> setAccentColor(int colorValue) async {
    final p = await _prefs;
    await p.setInt(_kAccentColor, colorValue);
  }

  static Future<int?> getAccentColor() async {
    final p = await _prefs;
    return p.getInt(_kAccentColor);
  }

  static Future<void> setThemeMode(String mode) async {
    final p = await _prefs;
    await p.setString(_kThemeMode, mode);
  }

  static Future<String> getThemeMode() async {
    final p = await _prefs;
    return p.getString(_kThemeMode) ?? 'dark';
  }

  // ---- Last session settings ----
  static Future<void> saveLastSettings({required int duration, required String level, required String focus}) async {
    final p = await _prefs;
    await p.setInt(_kLastDuration, duration);
    await p.setString(_kLastLevel, level);
    await p.setString(_kLastFocus, focus);
  }

  static Future<Map<String, dynamic>> getLastSettings() async {
    final p = await _prefs;
    return {
      'duration': p.getInt(_kLastDuration) ?? 20,
      'level': p.getString(_kLastLevel) ?? 'beginner',
      'focus': p.getString(_kLastFocus) ?? 'all',
    };
  }

  static Future<void> setVoiceEnabled(bool v) async => (await _prefs).setBool(_kVoiceEnabled, v);
  static Future<bool> getVoiceEnabled() async => (await _prefs).getBool(_kVoiceEnabled) ?? true;

  static Future<void> setMusicEnabled(bool v) async => (await _prefs).setBool(_kMusicEnabled, v);
  static Future<bool> getMusicEnabled() async => (await _prefs).getBool(_kMusicEnabled) ?? false;

  // ---- GitHub backup ----
  static Future<void> setGithubToken(String token) async => (await _prefs).setString(_kGithubToken, token);
  static Future<String?> getGithubToken() async => (await _prefs).getString(_kGithubToken);

  static Future<void> setGithubRepo(String repo) async => (await _prefs).setString(_kGithubRepo, repo);
  static Future<String?> getGithubRepo() async => (await _prefs).getString(_kGithubRepo);

  static Future<void> setAutoBackup(bool v) async => (await _prefs).setBool(_kAutoBackup, v);
  static Future<bool> getAutoBackup() async => (await _prefs).getBool(_kAutoBackup) ?? true;

  // ---- History & stats ----
  static Future<List<SessionHistoryEntry>> getHistory() async {
    final p = await _prefs;
    final raw = p.getStringList(_kHistory) ?? [];
    return raw.map((e) => SessionHistoryEntry.fromJson(json.decode(e))).toList();
  }

  static Future<void> addHistoryEntry(SessionHistoryEntry entry) async {
    final p = await _prefs;
    final raw = p.getStringList(_kHistory) ?? [];
    raw.add(json.encode(entry.toJson()));
    await p.setStringList(_kHistory, raw);

    final totalMin = p.getInt(_kTotalMinutes) ?? 0;
    final totalSessions = p.getInt(_kTotalSessions) ?? 0;
    await p.setInt(_kTotalMinutes, totalMin + entry.durationMinutes);
    await p.setInt(_kTotalSessions, totalSessions + 1);
    await p.setString(_kLastSessionDate, entry.date.toIso8601String());
  }

  static Future<Map<String, int>> getStats() async {
    final p = await _prefs;
    return {
      'totalMinutes': p.getInt(_kTotalMinutes) ?? 0,
      'totalSessions': p.getInt(_kTotalSessions) ?? 0,
    };
  }

  static Future<DateTime?> getLastSessionDate() async {
    final p = await _prefs;
    final s = p.getString(_kLastSessionDate);
    return s != null ? DateTime.parse(s) : null;
  }

  // ---- Favorites (store as JSON list of session configs) ----
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final p = await _prefs;
    final raw = p.getStringList(_kFavorites) ?? [];
    return raw.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
  }

  static Future<void> addFavorite(Map<String, dynamic> config) async {
    final p = await _prefs;
    final raw = p.getStringList(_kFavorites) ?? [];
    raw.add(json.encode(config));
    await p.setStringList(_kFavorites, raw);
  }

  static Future<void> removeFavoriteAt(int index) async {
    final p = await _prefs;
    final raw = p.getStringList(_kFavorites) ?? [];
    if (index >= 0 && index < raw.length) {
      raw.removeAt(index);
      await p.setStringList(_kFavorites, raw);
    }
  }

  // ---- Full backup payload (for GitHub backup) ----
  static Future<Map<String, dynamic>> buildBackupPayload() async {
    final history = await getHistory();
    final stats = await getStats();
    final favorites = await getFavorites();
    final lastSettings = await getLastSettings();
    return {
      'app': 'Alive',
      'exportedAt': DateTime.now().toIso8601String(),
      'stats': stats,
      'history': history.map((e) => e.toJson()).toList(),
      'favorites': favorites,
      'lastSettings': lastSettings,
    };
  }
}
