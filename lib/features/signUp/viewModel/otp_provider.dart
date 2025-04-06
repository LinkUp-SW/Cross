import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/services/otp_service.dart';
import 'package:link_up/features/signUp/state/otp_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';

final otpServiceProvider = Provider((ref) => OtpService());

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  final service = ref.watch(otpServiceProvider);
  final signUpNotifier = ref.read(signUpProvider.notifier);
  return OtpNotifier(service, signUpNotifier);
});

class OtpNotifier extends StateNotifier<OtpState> {
  final OtpService _otpService;
  final SignUpNotifier _signUpNotifier;
  OtpNotifier(this._otpService, this._signUpNotifier) : super(OtpInitial());

  Future<void> sendOtp() async {
    state = OtpLoading();
    try {
      
      final success = await _otpService.sendOtp(_signUpNotifier.state.email);
      if (success) {
        state = OtpSent();
      } else {
        state = OtpError("Failed to send OTP");
      }
    } catch (e) {
      state = OtpError("Failed to send OTP");
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = OtpLoading();
    print(otp);
    print(_signUpNotifier.state.email);
    try {
      final success =
          await _otpService.verifyOtp(otp, _signUpNotifier.state.email);
      if (success) {
        state = OtpSuccess();
      } else {
        state = OtpError("Invalid OTP");
      }
    } catch (e) {
      state = OtpError("Failed to verify OTP");
    }
  }
}
