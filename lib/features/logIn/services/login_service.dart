//api hits and response data transfere
import 'dart:convert';
import 'dart:developer';

import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/logIn/model/login_model.dart';

class LogInService extends BaseService {
  Future<Map<String, dynamic>> logIn(LogInModel logInModel) async {
    final response = await post(
      "auth/login",
      body: {"email": logInModel.email, "password": logInModel.password},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    const String endpointTemplate = 'api/v1/user/profile/bio/:user_id';
    final response = await super.get(
      endpointTemplate,
      routeParameters: {'user_id': InternalEndPoints.userId},
    );

    if (response.statusCode == 200) {
      log("User data fetched successfully");
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      log("Unauthorized access. Please log in again.");
      throw Exception('Unauthorized access. Please log in again.');
    } else if (response.statusCode == 404) {
      log("User not found.");
      throw Exception('User not found.');
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
