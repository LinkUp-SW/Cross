import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/model/verfication_model.dart';
import 'package:link_up/features/signUp/services/verfication_service.dart';
import 'package:link_up/features/signUp/state/verfication_state.dart';

final verficationServiceProvider = Provider((ref) => VerficationService());

final verficationProvider = StateNotifierProvider<VerficationNotifier, VerificationState>((ref) {
  final service = ref.watch(verficationServiceProvider);
  return VerficationNotifier(service);
});


class VerficationNotifier extends StateNotifier<VerificationState> {
  final VerficationService _verficationService;

  VerficationNotifier(this._verficationService) : super(VerificationInitial());

  Future<void> verifyCode(String code) async {
    try {
      state = VerificationLoading();
      final success = await _verficationService.verifyCode(VerficationModel(code: code));
      if (success == true) {
        state = VerificationSuccess();
      } else {
        state = VerificationFailure("Failed to verify code");
      }
    } catch (e) {
      state = VerificationFailure("Failed to verify code");
    }
  }

  String? validateCode(String? code) {
    if (code == null || code.isEmpty || code.length < 4) {
      return "Please enter a valid code";
    }
    return null;
  }

  Future<void> resendCode() async {
    try {
      state = ResendCodeLoading();
      final success = await _verficationService.resendCode();
      if (success == true) {
        state = VerificationInitial();
      } else {
        state = VerificationFailure("Failed to resend code");
      }
    } catch (e) {
      state = VerificationFailure("Failed to resend code");
    }
  }

}