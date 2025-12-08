import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  
  AppSettings get settings => _settings;
  
  static const String _settingsKey = 'app_settings';

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final decoded = jsonDecode(settingsJson);
        _settings = AppSettings.fromJson(decoded);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading settings: $e');
      }
    }
  }

  Future<void> saveSettings(AppSettings newSettings) async {
    try {
      _settings = newSettings;
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving settings: $e');
      }
    }
  }

  Future<void> updateMapillaryApiKey(String apiKey) async {
    await saveSettings(_settings.copyWith(mapillaryApiKey: apiKey));
  }

  Future<void> updateGeminiApiKey(String apiKey) async {
    await saveSettings(_settings.copyWith(geminiApiKey: apiKey));
  }

  Future<void> togglePremiumMode() async {
    await saveSettings(_settings.copyWith(isPremiumMode: !_settings.isPremiumMode));
  }
}
