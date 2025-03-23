import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  LogInNotifier(this._logInService) : super(LogInInitialState());

  Future<void> logIn(String email, String password) async {
    state = LogInLoadingState(); // Show loading indicator
    try {
      final success = await _logInService
          .logIn(LogInModel(email: email, password: password));
      if (success) {
        state = LogInSuccessState();
      } else {
        state = LogInErrorState("Invalid credentials");
      }
    } catch (e) {
      print(e.toString());
      state = LogInErrorState(e.toString());
    }
  }
}
