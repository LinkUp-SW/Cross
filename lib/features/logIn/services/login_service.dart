//api hits and response data transfere
import 'dart:convert';

import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/logIn/model/login_model.dart';

class LogInService extends BaseService {
  Future<Map<String,dynamic>> logIn(LogInModel logInModel) async {
    final response = await post(
      "auth/login",
      body: {"email": logInModel.email, "password": logInModel.password},
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
