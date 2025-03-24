class PastJobDetailsState {}

class PastJobDetailsError extends PastJobDetailsState {
  final String error;

  PastJobDetailsError(this.error);
}

class Student extends PastJobDetailsState {}

class Job extends PastJobDetailsState {}