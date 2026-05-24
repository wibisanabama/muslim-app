import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageViewModel extends ChangeNotifier {
  static const _key = 'app_language';

  // Available options: 'system', 'en', 'id'
  String _selectedLanguage = 'system';
  String get selectedLanguage => _selectedLanguage;

  LanguageViewModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString(_key) ?? 'system';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (_selectedLanguage == code) return;
    _selectedLanguage = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  /// Check if resolved locale is English
  bool get isEnglish {
    if (_selectedLanguage == 'en') return true;
    if (_selectedLanguage == 'id') return false;
    
    // Bawaan Sistem -> check platform locale
    try {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      return systemLocale.startsWith('en');
    } catch (_) {
      return false;
    }
  }

  /// UI Label representing current choice (always localized appropriately)
  String get currentLabel {
    switch (_selectedLanguage) {
      case 'system':
        return translate('Bawaan Sistem', 'System Default');
      case 'en':
        return 'English';
      case 'id':
        return 'Indonesia';
      default:
        return translate('Bawaan Sistem', 'System Default');
    }
  }

  /// Localized label names for the dialog
  String get systemLabel => translate('Bawaan Sistem', 'System Default');
  String get englishLabel => 'English';
  String get indonesianLabel => 'Indonesia';

  /// Main translator helper function
  String translate(String idText, String enText) {
    return isEnglish ? enText : idText;
  }
}
