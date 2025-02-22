

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  ThemeNotifier() : super();

  void toggleTheme() {
    if(state == ThemeMode.system){
      state = ThemeMode.light;
  }
  else if(state == ThemeMode.light){
    state = ThemeMode.dark;
  }
  else{
    state = ThemeMode.system;
  }
}

  @override
  ThemeMode build() {
    return ThemeMode.system;
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier,ThemeMode>(() => ThemeNotifier());
