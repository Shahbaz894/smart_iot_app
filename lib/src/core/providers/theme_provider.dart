import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:shared_preferences/shared_preferences.dart';



class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme(); // load saved theme on initialization
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, state == ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, state == ThemeMode.dark);
  }
}

// Riverpod provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
      (ref) => ThemeNotifier(),
);
