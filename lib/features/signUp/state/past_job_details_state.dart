class PastJobDetailsState {}

class PastJobDetailsInitial extends PastJobDetailsState {}

class PastJobDetailsLoading extends PastJobDetailsState {}

class PastJobDetailsSuccess extends PastJobDetailsState {}

class PastJobDetailsError extends PastJobDetailsState {
  final String error;

  PastJobDetailsError(this.error);
}

class Student extends PastJobDetailsState {}

class Job extends PastJobDetailsState {}
