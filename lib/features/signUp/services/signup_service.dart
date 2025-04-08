import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/signUp/model/signup_global_model.dart';

class SignUpService extends BaseService {
  Future<bool> sendDataToBackend(SignUpModel signUpData) async {
    final response = await post(
      "api/v1/user/signup/starter",
      body: signUpData.toJson(),
    );

    if (response.statusCode == 200) {
      return true; // Successfully sent data
    } else {
      return false; // API request failed
    }
  }
}
