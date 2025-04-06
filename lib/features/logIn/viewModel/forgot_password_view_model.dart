import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/logIn/services/forgot_password_service.dart';
import 'package:link_up/features/logIn/state/forgot_password_state.dart';

final forgotPasswordServiceProvider =
    Provider((ref) => ForgotPasswordService());

final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  final service = ref.watch(forgotPasswordServiceProvider);
  return ForgotPasswordNotifier(service);
});

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final ForgotPasswordService _forgotPasswordService;

  ForgotPasswordNotifier(this._forgotPasswordService)
      : super(const ForgotPasswordInitial());

  Future<void> forgotPassword(String email) async {
    state = const ForgotPasswordLoading();
    try {
      final success =
          await _forgotPasswordService.sendPasswordResetEmail(email);
      if (success) {
        state = const ForgotPasswordSuccess();
      } else {
        state = const ForgotPasswordFailure("Failed to send password reset email");
      }
    } catch (e) {
      state = const ForgotPasswordFailure("Failed to send password reset email");
    }
  }
}
