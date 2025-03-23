import 'package:http/http.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/signUp/model/email_password_model.dart';

class EmailPasswordService extends BaseService {
  Future<bool> verifyEmail(EmailPasswordModel email) async {
    try {
      final response =
          await this.post('api/v1/user/verify-email', {'email': email.email});

      print(response.statusCode);
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
