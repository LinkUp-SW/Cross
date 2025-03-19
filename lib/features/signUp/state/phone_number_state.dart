sealed class PhoneNumberState {}

class PhoneNumberinitial extends PhoneNumberState {}

class PhoneNumberValid extends PhoneNumberState {}

class PhoneNumberInvalid extends PhoneNumberState {
  final String errorMessage;

  PhoneNumberInvalid(this.errorMessage);
}

class LoadingPhoneNumber extends PhoneNumberState {}
