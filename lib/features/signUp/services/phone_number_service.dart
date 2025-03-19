import 'package:link_up/features/signUp/model/phone_number_model.dart';

class PhoneNumberService {
  String? phoneNumber;

  Future<bool?> setPhoneNumber(PhoneNumberModel phoneNumber) async {
    try {
      await Future.delayed(Duration(seconds: 1));

      this.phoneNumber = '+${phoneNumber.countryCode} ${phoneNumber.number}';
      return true;
    } catch (e) {
      return false;
    }
  }

  String? getPhoneNumber() {
    return phoneNumber;
  }

  Future<bool> sendphonenumber() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

}



