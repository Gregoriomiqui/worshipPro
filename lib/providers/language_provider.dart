import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para manejar el idioma de la aplicación
class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('es', '');
  static const String _languageKey = 'language_code';

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  /// Carga el idioma guardado en las preferencias
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'es';
      _locale = Locale(languageCode, '');
      notifyListeners();
    } catch (e) {
      // Si hay error, mantener español como predeterminado
      _locale = const Locale('es', '');
    }
  }

  /// Cambia el idioma de la aplicación
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    // Guardar en preferencias
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error al guardar idioma: $e');
    }
  }

  /// Cambia el idioma usando el código de idioma
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode, ''));
  }

  /// Alterna entre español e inglés
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'es' 
        ? const Locale('en', '') 
        : const Locale('es', '');
    await setLocale(newLocale);
  }

  /// Verifica si el idioma actual es español
  bool get isSpanish => _locale.languageCode == 'es';

  /// Verifica si el idioma actual es inglés
  bool get isEnglish => _locale.languageCode == 'en';
}
