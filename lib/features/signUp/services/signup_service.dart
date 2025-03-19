import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link_up/features/signUp/model/signup_global_model.dart';

class SignUpService {
  Future<bool> sendDataToBackend(SignUpModel signUpData) async {
    final url = Uri.parse("https://yourbackend.com/signup"); // Replace with actual API endpoint

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(signUpData.toJson()), // Convert model to JSON format
    );

    if (response.statusCode == 200) {
      return true; // Successfully sent data
    } else {
      return false; // API request failed
    }
  }
}
