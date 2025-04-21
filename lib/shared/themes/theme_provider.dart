

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/storage.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  ThemeNotifier() : super();

  void setTheme(ThemeMode theme) async {
    state = theme;
    await saveThemeToStorage(theme);
  }

  void setInitialTheme() async {
    final theme = await getThemeFromStorage();
    state = theme;
  }

  @override
  ThemeMode build() {
    return ThemeMode.system;
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier,ThemeMode>(() => ThemeNotifier());
