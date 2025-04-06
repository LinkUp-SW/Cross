class OtpState {}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {}

class OtpSent extends OtpState {}

class OtpError extends OtpState {
  final String message;

  OtpError(this.message);
}
