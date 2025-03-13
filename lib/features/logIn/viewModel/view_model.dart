//riverpod setup and page business logic
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel extends ChangeNotifier {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty || value.length < 10 || !value.contains("@")) {
      return 'Please enter your email or phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Please enter a valid password';
    }
    return null;
  }
}

final loginViewModelProvider = ChangeNotifierProvider((ref) => LoginViewModel());