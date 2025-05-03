// page state managemnt operations

sealed class LogInState {
  const LogInState();
}

class LogInLoadingState extends LogInState {
  const LogInLoadingState();
}

class LogInSuccessState extends LogInState {
  final bool isAdmin;
  const LogInSuccessState(
    {this.isAdmin = false}
  );
}

class LogInErrorState extends LogInState {
  final String message;
  const LogInErrorState(this.message);
}

class LogInInitialState extends LogInState {
  final String? savedEmail;
  final String? savedPassword;
  final bool rememberMe;

  const LogInInitialState({
    this.savedEmail,
    this.savedPassword,
    this.rememberMe = false,
  });
}