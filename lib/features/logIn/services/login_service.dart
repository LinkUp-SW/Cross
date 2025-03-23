//api hits and response data transfere

import 'dart:convert';

import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/logIn/model/login_model.dart';

class LogInService extends BaseService {
  Future<bool> logIn(LogInModel logInModel) async {
    final response = await post("api/auth/login",
        {"email": logInModel.email, "password": logInModel.password});

    print(jsonDecode(response.body));
    print(response.statusCode);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
