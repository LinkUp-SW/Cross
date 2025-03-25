import 'package:link_up/features/signUp/model/verfication_model.dart';

class VerficationService {
  Future<bool?> verifyCode(VerficationModel code) async {
    try {
      await Future.delayed(Duration(seconds: 2));
      if (code.code == '1234') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> resendCode() async {
    try {
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}
