import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/model/email_password_model.dart';
import 'package:link_up/features/signUp/services/email_password_service.dart';
import 'package:link_up/features/signUp/state/email_password_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';

final emailPasswordServiceProvider = Provider((ref) => EmailPasswordService());

final emailPasswordProvider =
    StateNotifierProvider<EmailPasswordNotifier, EmailPasswordState>((ref) {
  final service = ref.watch(emailPasswordServiceProvider);
  final signUpNotifier = ref.read(signUpProvider.notifier);
  return EmailPasswordNotifier(service, signUpNotifier);
});

class EmailPasswordNotifier extends StateNotifier<EmailPasswordState> {
  final EmailPasswordService _emailPasswordService;
  final SignUpNotifier _signUpNotifier;

  EmailPasswordNotifier(this._emailPasswordService, this._signUpNotifier)
      : super(EmailPasswordIntial());

  Future<void> verifyEmail(String email, String password) async {
    try {
      state = LoadingEmailPassword();
      final sucess = await _emailPasswordService
          .verifyEmail(EmailPasswordModel(email: email, password: password));
      if (sucess) {
        state = EmailPasswordValid();
        _signUpNotifier.updateUserData(email: email, password: password);
        print('${_signUpNotifier.state.email}');
      } else {
        state = EmailPasswordInvalid("Email could not be verified");
      }
    } catch (e) {
      print(e.toString());
      state = EmailPasswordInvalid("There was an error with the application");
    }
  }
}
