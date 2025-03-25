sealed class NameState {}

class NameInitial extends NameState {}

class NameValid extends NameState {}

class NameInvalid extends NameState {
  final String errorMessage;

  NameInvalid(this.errorMessage);
}

class NameLoading extends NameState {}