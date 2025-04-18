// for internal endpoints like token storage

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/utils/global_keys.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await secureStorage.write(key: "token", value: token);
}

Future<String?> getToken() async {
  return await secureStorage.read(key: "token");
}

Future<void> rememberMe(String email, String password) async {
  await secureStorage.write(key: "email", value: email);
  await secureStorage.write(key: "password", value: password);
}

Future<bool> checkForRememberMe() async {
  final email = await secureStorage.read(key: "email");
  final password = await secureStorage.read(key: "password");
  if (email != null && password != null) {
    return true; // Credentials are stored
  }
  return false; // No credentials found
}

Future returncred() async {
  final email = await secureStorage.read(key: "email");
  final password = await secureStorage.read(key: "password");
  return [
    email,
    password,
  ]; // No credentials found
}

Future<void> logout(BuildContext context) async {
  await secureStorage.delete(key: "token");
  await secureStorage.delete(key: "email");
  await secureStorage.delete(key: "password");
  (navigatorKey.currentContext ?? context).go('/login');
}


Future<void> saveThemeToStorage(ThemeMode theme) async {
  await secureStorage.write(key: "theme", value: theme.toString());
}

Future<ThemeMode> getThemeFromStorage() async {
  final themeString = await secureStorage.read(key: "theme");
  if (themeString == ThemeMode.dark.toString()) {
    return ThemeMode.dark;
  } else if (themeString == ThemeMode.light.toString()) {
    return ThemeMode.light;
  } else {
    return ThemeMode.system; // Default to system theme
  }   
}
