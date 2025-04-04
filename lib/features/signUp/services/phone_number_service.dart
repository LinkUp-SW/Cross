import 'package:link_up/features/signUp/model/phone_number_model.dart';

class PhoneNumberService {

  Future<bool?> setPhoneNumber(PhoneNumberModel phoneNumber) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendphonenumber() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

}



