
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/logIn/model/login_model.dart';
import 'package:link_up/features/logIn/services/login_service.dart';
import 'package:link_up/features/logIn/state/login_state.dart';

final logInServiceProvider = Provider((ref) => LogInService());

final logInProvider = StateNotifierProvider<LogInNotifier, LogInState>((ref) {
  final service = ref.watch(logInServiceProvider);
  return LogInNotifier(service);
});

class LogInNotifier extends StateNotifier<LogInState> {
  final LogInService _logInService;

  LogInNotifier(this._logInService) : super(const LogInInitialState());

  Future<void> logIn(String email, String password) async {
    state = const LogInLoadingState(); // Show loading indicator
    try {
      final success = await _logInService
          .logIn(LogInModel(email: email, password: password));
      if (success) {
        state = const LogInSuccessState();
      } else {
        state = const LogInErrorState("Invalid credentials");
      }
    } catch (e) {
      print(e.toString());
      state = const LogInErrorState(
          'There was an error logging in. Please try again.');
    }
  }

  Future<void> checkStoredCredentials() async {
    // Check if email and password are stored in secure storage
    if (await checkForRememberMe()) {
      // Retrieve stored credentials
      final credentials = await returncred();

      // Automatically log in if credentials are found
      logIn(credentials[0], credentials[1]);
    }
  }
}
