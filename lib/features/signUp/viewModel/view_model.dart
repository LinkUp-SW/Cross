//riverpod setup and page business logic
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//////////////////////////// SigningUpViewModel  ////////////////////////////
class SigningUpViewModel extends ChangeNotifier {
  String? validateEmail(String? value) {
    if (value == null ||
        value.isEmpty ||
        value.length < 10 ||
        !value.contains("@")) {
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

//////////////////////////// NamingViewModel  ////////////////////////////
final signingUpViewModelprovider =
    ChangeNotifierProvider((ref) => SigningUpViewModel());

class NamingViewModel extends ChangeNotifier {
  String? validateName(String? value, String? error) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Please Insert a valid $error';
    }
    return null;
  }
}

final namingViewModelProvider =
    ChangeNotifierProvider((ref) => NamingViewModel());








//////////////////////////// GetPhoneNumberViewModel  ////////////////////////////
class GetPhoneNumberViewModel extends ChangeNotifier {
  String phoneNumber = '';
  
  void setPhoneNumber(String value) {
    phoneNumber = value;
    notifyListeners();
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}

final getPhoneNumberViewModelProvider =
    ChangeNotifierProvider((ref) => GetPhoneNumberViewModel());