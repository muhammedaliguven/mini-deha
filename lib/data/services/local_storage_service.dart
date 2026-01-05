import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _kGuestIdKey = 'guest_id';
  static const String _kScoresKey = 'skill_scores';
  static const String _kWatchedKey = 'watched_videos';

  SharedPreferences? _prefs;
  String? _guestId;

  // Initialize: Call this in main.dart or HomeScreen
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // 1. Ensure Guest ID
    _guestId = _prefs?.getString(_kGuestIdKey);
    if (_guestId == null) {
      _guestId = const Uuid().v4();
      await _prefs?.setString(_kGuestIdKey, _guestId!);
      debugPrint("New Guest ID generated: $_guestId");
    } else {
      debugPrint("Existing Guest ID: $_guestId");
    }
  }

  String get guestId => _guestId ?? 'unknown-guest';

  // Helper to generate monthly key: "skill_scores_2026_1"
  String _getMonthKey(DateTime date) {
    return '${_kScoresKey}_${date.year}_${date.month}';
  }

  // Helper for monthly watched videos: "watched_videos_2026_1"
  String _getWatchedKey(DateTime date) {
    return '${_kWatchedKey}_${date.year}_${date.month}';
  }

  // Increment score for a skill (Current Month)
  Future<bool> incrementSkillScore(String skill, String videoId) async {
    if (_prefs == null) await init();

    DateTime now = DateTime.now();
    String watchedKey = _getWatchedKey(now);

    // 1. Check if video already watched THIS MONTH
    List<String> watchedList = _prefs?.getStringList(watchedKey) ?? [];
    if (watchedList.contains(videoId)) {
      debugPrint("Video $videoId already counted for stats in this month.");
      return false;
    }

    // 2. Mark as watched
    watchedList.add(videoId);
    await _prefs?.setStringList(watchedKey, watchedList);

    // 3. Update Score for CURRENT MONTH
    String key = _getMonthKey(now);
    String? scoresJson = _prefs?.getString(key);
    Map<String, dynamic> scores = {};
    if (scoresJson != null) {
      try {
        scores = jsonDecode(scoresJson);
      } catch (e) {
        debugPrint("Error parsing scores: $e");
      }
    }

    // Default to 0, increment by 1
    int currentScore = (scores[skill] as int?) ?? 0;
    scores[skill] = currentScore + 1;

    // Save
    await _prefs?.setString(key, jsonEncode(scores));
    debugPrint("Skill Updated ($key): $skill -> ${scores[skill]}");
    return true;
  }

  // Get scores for specific month (Defaults to Now)
  Future<Map<String, int>> getSkillScores({DateTime? date}) async {
    if (_prefs == null) await init();
    
    DateTime targetDate = date ?? DateTime.now();
    String key = _getMonthKey(targetDate);
    
    String? scoresJson = _prefs?.getString(key);
    if (scoresJson == null) return {};

    try {
      Map<String, dynamic> rawMap = jsonDecode(scoresJson);
      return rawMap.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

}
