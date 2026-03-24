import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Nome da box para configurações simples
const String _settingsBoxName = 'settings';
const String _themeKey = 'theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Carrega o tema salvo ao iniciar
  void _loadTheme() {
    final box = Hive.box(_settingsBoxName);
    final savedTheme = box.get(_themeKey, defaultValue: 'system');
    
    state = _stringToThemeMode(savedTheme);
  }

  // Altera o tema e salva no Hive
  void setTheme(ThemeMode mode) {
    state = mode;
    final box = Hive.box(_settingsBoxName);
    box.put(_themeKey, mode.name); // Salva como string: 'light', 'dark' ou 'system'
  }

  ThemeMode _stringToThemeMode(String theme) {
    switch (theme) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}