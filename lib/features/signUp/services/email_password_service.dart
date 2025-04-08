import 'dart:convert';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/signUp/model/email_password_model.dart';

class EmailPasswordService extends BaseService {
  Future<bool> verifyEmail(EmailPasswordModel email) async {
    try {
      final response = await post(
        'api/v1/user/verify-email',
        body: {
          'email': email.email,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> hashPassword(String password) async {
    try {
      final response = await get(
        "user/hash-password",
        queryParameters: {
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['password'];
      } else {
        return password;
      }
    } catch (e) {
      return password;
    }
  }
}
