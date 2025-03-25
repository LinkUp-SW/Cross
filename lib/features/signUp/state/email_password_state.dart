sealed class EmailPasswordState {}

class EmailPasswordIntial extends EmailPasswordState {}

class EmailPasswordValid extends EmailPasswordState {}

class EmailPasswordInvalid extends EmailPasswordState {
  final String errorMessage;

  EmailPasswordInvalid(this.errorMessage);
}

class LoadingEmailPassword extends EmailPasswordState {}