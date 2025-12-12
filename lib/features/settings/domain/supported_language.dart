import 'package:flutter/material.dart';

/// Supported languages in Apothy app
enum SupportedLanguage {
  english('en', 'English', 'English'),
  spanish('es', 'Español', 'Spanish'),
  french('fr', 'Français', 'French'),
  chinese('zh', '中文', 'Chinese'),
  portuguese('pt', 'Português', 'Portuguese'),
  thai('th', 'ไทย', 'Thai'),
  vietnamese('vi', 'Tiếng Việt', 'Vietnamese');

  const SupportedLanguage(this.code, this.nativeName, this.englishName);

  /// ISO 639-1 language code (e.g., 'en', 'es')
  final String code;

  /// Display name in the language itself (e.g., 'Español' for Spanish)
  final String nativeName;

  /// Display name in English (for debugging/logs)
  final String englishName;

  /// Get Flutter Locale object for this language
  Locale get locale => Locale(code);

  /// Get language from code, returns null if not found
  static SupportedLanguage? fromCode(String? code) {
    if (code == null) return null;
    try {
      return SupportedLanguage.values.firstWhere(
        (lang) => lang.code == code,
      );
    } catch (_) {
      return null;
    }
  }
}
