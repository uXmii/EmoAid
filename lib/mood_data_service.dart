// lib/services/mood_data_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../mood_entry.dart';

// Singleton service to manage mood data across the app
class MoodDataService extends ChangeNotifier {
  static final MoodDataService _instance = MoodDataService._internal();
  factory MoodDataService() => _instance;
  MoodDataService._internal();

  List<MoodEntry> _moodHistory = [];
  bool _isLoading = false;

  // Getters
  List<MoodEntry> get moodHistory => List.unmodifiable(_moodHistory);
  bool get isLoading => _isLoading;
  bool get hasData => _moodHistory.isNotEmpty;

  // Initialize and load data
  Future<void> initialize() async {
    await loadMoodHistory();
  }

  // Load mood history from SharedPreferences
  Future<void> loadMoodHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('mood_history') ?? [];
      
      _moodHistory = historyJson
          .map((entry) => MoodEntry.fromJson(json.decode(entry)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('Loaded ${_moodHistory.length} mood entries from storage');
    } catch (e) {
      print('Error loading mood history: $e');
      _moodHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      _moodHistory.insert(0, entry);
      await _saveMoodHistory();
      notifyListeners();
      print('Added new mood entry: ${entry.moodLabel}');
    } catch (e) {
      print('Error adding mood entry: $e');
      throw e;
    }
  }

  // Update existing mood entry
  Future<void> updateMoodEntry(int index, MoodEntry entry) async {
    if (index >= 0 && index < _moodHistory.length) {
      try {
        _moodHistory[index] = entry;
        await _saveMoodHistory();
        notifyListeners();
        print('Updated mood entry at index $index');
      } catch (e) {
        print('Error updating mood entry: $e');
        throw e;
      }
    }
  }

  // Delete mood entry
  Future<void> deleteMoodEntry(int index) async {
    if (index >= 0 && index < _moodHistory.length) {
      try {
        final removed = _moodHistory.removeAt(index);
        await _saveMoodHistory();
        notifyListeners();
        print('Deleted mood entry: ${removed.moodLabel}');
      } catch (e) {
        print('Error deleting mood entry: $e');
        throw e;
      }
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mood_history');
      _moodHistory.clear();
      notifyListeners();
      print('Cleared all mood data');
    } catch (e) {
      print('Error clearing mood data: $e');
      throw e;
    }
  }

  // Private method to save to SharedPreferences
  Future<void> _saveMoodHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _moodHistory
          .map((entry) => json.encode(entry.toJson()))
          .toList();
      
      await prefs.setStringList('mood_history', historyJson);
      print('Saved ${_moodHistory.length} mood entries to storage');
    } catch (e) {
      print('Error saving mood history: $e');
      throw e;
    }
  }

  // Get recent entries (for dashboard/quick view)
  List<MoodEntry> getRecentEntries({int limit = 5}) {
    return _moodHistory.take(limit).toList();
  }

  // Get entries by date range
  List<MoodEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    return _moodHistory.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  // Get entries by mood value
  List<MoodEntry> getEntriesByMood(int moodValue) {
    return _moodHistory.where((entry) => entry.mood == moodValue).toList();
  }

  // Calculate average mood
  double getAverageMood() {
    if (_moodHistory.isEmpty) return 0.0;
    final sum = _moodHistory.map((e) => e.mood).reduce((a, b) => a + b);
    return sum / _moodHistory.length;
  }

  // Get mood trend (last 7 days vs previous 7 days)
  double getMoodTrend() {
    if (_moodHistory.length < 14) return 0.0;
    
    final now = DateTime.now();
    final last7Days = _moodHistory.where((entry) => 
        now.difference(entry.timestamp).inDays <= 7).toList();
    final previous7Days = _moodHistory.where((entry) {
      final daysDiff = now.difference(entry.timestamp).inDays;
      return daysDiff > 7 && daysDiff <= 14;
    }).toList();
    
    if (last7Days.isEmpty || previous7Days.isEmpty) return 0.0;
    
    final recent = last7Days.map((e) => e.mood).reduce((a, b) => a + b) / last7Days.length;
    final previous = previous7Days.map((e) => e.mood).reduce((a, b) => a + b) / previous7Days.length;
    
    return recent - previous;
  }

  // Get most common mood
  String getMostCommonMood() {
    if (_moodHistory.isEmpty) return 'No data';
    
    final moodCounts = <String, int>{};
    for (final entry in _moodHistory) {
      moodCounts[entry.moodLabel] = (moodCounts[entry.moodLabel] ?? 0) + 1;
    }
    
    return moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Export data (for backup/sharing)
  String exportData() {
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalEntries': _moodHistory.length,
      'entries': _moodHistory.map((e) => e.toJson()).toList(),
    };
    return json.encode(exportData);
  }

  // Import data (for restore)
  Future<void> importData(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      final entries = (data['entries'] as List)
          .map((e) => MoodEntry.fromJson(e))
          .toList();
      
      _moodHistory = entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _saveMoodHistory();
      notifyListeners();
      print('Imported ${_moodHistory.length} mood entries');
    } catch (e) {
      print('Error importing data: $e');
      throw e;
    }
  }
}