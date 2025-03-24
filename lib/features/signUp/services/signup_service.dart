import 'package:http/http.dart' as http;
import 'package:link_up/core/services/base_service.dart';
import 'dart:convert';
import 'package:link_up/features/signUp/model/signup_global_model.dart';

class SignUpService extends BaseService {
  Future<bool> sendDataToBackend(SignUpModel signUpData) async {

    final response=await this.post("api/v1/user/signup/starter", signUpData.toJson());

    if (response.statusCode == 200) {
      return true; // Successfully sent data
    } else {
      return false; // API request failed
    }
  }
}
