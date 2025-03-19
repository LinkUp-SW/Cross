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

//////////////////////////// VerificationViewModel  ////////////////////////////
class VerificationViewModel extends ChangeNotifier {
  String verificationCode = '';

  void setVerificationCode(String value) {
    verificationCode = value;
    notifyListeners();
  }

  String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Please enter a valid verification code';
    }
    return null;
  }
}

final verificationViewModelProvider =
    ChangeNotifierProvider((ref) => VerificationViewModel());

//////////////////////////// PastJobDetailsViewModel  ////////////////////////////
class PastJobDetailsViewModel extends ChangeNotifier {
  String jobTitle = '';
  String companyName = '';
  String jobDescription = '';
  String startDate = '';
  String school = '';
  DateTime? selectedDate;

  void setJobTitle(String value) {
    jobTitle = value;
    notifyListeners();
  }

  void setCompanyName(String value) {
    companyName = value;
    notifyListeners();
  }

  void setJobDescription(String value) {
    jobDescription = value;
    notifyListeners();
  }

  String? validateJobTitle(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Please enter a valid job title';
    }
    return null;
  }

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Please enter a valid company name';
    }
    return null;
  }

  String? validateJobDescription(String? value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return 'Please enter a valid job description';
    }
    return null;
  }

  

  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
        selectedDate = pickedDate;
    }
  }
}

final pastJobDetailsViewModelProvider =
    ChangeNotifierProvider((ref) => PastJobDetailsViewModel());
