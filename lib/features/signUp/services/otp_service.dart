import 'package:link_up/core/services/base_service.dart';

class OtpService extends BaseService {
  Future<bool> sendOtp(String? email) async {
    try {
      final response = await post(
        "api/v1/user/send-otp",
        body: {
          "email": email,
        },
      );
      if (response.statusCode != 200) {
        return false;
      }
      return true;
    } catch (e) {
      throw Exception('Failed to get OTP');
    }
  }

  Future<bool> verifyOtp(String otp, String? email) async {
    try {
      final response = await post(
        "user/verify-otp",
        body: {
          "otp": otp,
          "email": email,
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to verify OTP');
    }
  }
}
