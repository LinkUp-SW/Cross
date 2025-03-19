// page state managemnt operations

sealed class LogInState {
  const LogInState();
}

class LogInInitialState extends LogInState {
  const LogInInitialState();
}

class LogInLoadingState extends LogInState {
  const LogInLoadingState();
}

class LogInSuccessState extends LogInState {
  const LogInSuccessState();
}

class LogInErrorState extends LogInState {
  final String message;
  const LogInErrorState(this.message);
}
