// for internal endpoints like token storage

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/utils/globalKeys.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await secureStorage.write(key: InternalEndPoints.token, value: token);
}

Future<String?> getToken() async {
  return await secureStorage.read(key: InternalEndPoints.token);
}

Future<void> logout(BuildContext context) async {
  await secureStorage.delete(key: InternalEndPoints.token);
  (navigatorKey.currentContext ?? context).go('/login');
}