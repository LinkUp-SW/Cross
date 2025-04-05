
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/logIn/model/login_model.dart';
import 'package:link_up/features/logIn/services/login_service.dart';
import 'package:link_up/features/logIn/state/login_state.dart';
import 'package:link_up/features/logIn/viewModel/user_data_vm.dart';

final logInServiceProvider = Provider((ref) => LogInService());

final logInProvider = StateNotifierProvider<LogInNotifier, LogInState>((ref) {
  final service = ref.watch(logInServiceProvider);
  return LogInNotifier(service);
});

class LogInNotifier extends StateNotifier<LogInState> {
  final LogInService _logInService;

  LogInNotifier(this._logInService) : super(const LogInInitialState());

  Future<void> logIn(String email, String password,WidgetRef ref) async {
    state = const LogInLoadingState(); // Show loading indicator
    try {
      final success = await _logInService
          .logIn(LogInModel(email: email, password: password)).catchError((error, stackTrace) {
            state = const LogInErrorState("Invalid credentials");
            throw error;
          });
      if (success.isNotEmpty) {
        ref.read(userDataProvider.notifier).setUserId(success['user']['id']);
        await ref.read(userDataProvider.notifier).getProfileUrl();
        state = const LogInSuccessState();
      }
    } catch (e) {
      print(e.toString());
      state = const LogInErrorState(
          'There was an error logging in. Please try again.');
    }
  }

  Future<void> checkStoredCredentials(WidgetRef ref) async {
    // Check if email and password are stored in secure storage
    if (await checkForRememberMe()) {
      // Retrieve stored credentials
      final credentials = await returncred();

      // Automatically log in if credentials are found

      logIn(credentials[0], credentials[1],ref);
    }
  }
}
