sealed class VerificationState {
  const VerificationState();
}

class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

class VerificationSuccess extends VerificationState {
  const VerificationSuccess();
}

class VerificationFailure extends VerificationState {
  final String message;

  const VerificationFailure(this.message);
}

class ResendCodeLoading extends VerificationState {
  const ResendCodeLoading();
}