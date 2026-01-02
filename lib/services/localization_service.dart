import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('en');
  Map<String, String> _localizedStrings = {};

  Locale get currentLocale => _currentLocale;

  // Initialize and load saved language preference
  Future<Locale> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode);
    await load(_currentLocale);
    return _currentLocale;
  }

  // Load translations from JSON file
  Future<void> load(Locale locale) async {
    _currentLocale = locale;
    String jsonString = await rootBundle.loadString(
      'lib/l10n/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  // Save language preference
  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    _currentLocale = locale;
    await load(locale);
  }

  // Get translated string
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Toggle between Arabic and English
  Future<Locale> toggleLanguage() async {
    final newLocale = _currentLocale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    await changeLanguage(newLocale);
    return newLocale;
  }
}

// Extension to make translations easier to use
extension LocalizationExtension on String {
  String get tr => LocalizationService().translate(this);
}

class AppLocalizations {
  final Locale locale;
  final LocalizationService _localizationService = LocalizationService();

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key) => _localizationService.translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await LocalizationService().load(locale);
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
