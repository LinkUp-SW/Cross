import 'package:link_up/core/services/base_service.dart';

class ForgotPasswordService extends BaseService {
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      final response =
          await post("api/v1/user/forget-password", {"email": email});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
