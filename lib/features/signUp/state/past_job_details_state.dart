class PastJobDetailsState {}

class PastJobDetailsInitial extends PastJobDetailsState {}

class PastJobDetailsLoading extends PastJobDetailsState {}

class PastJobDetailsSuccess extends PastJobDetailsState {}

class PastJobDetailsError extends PastJobDetailsState {
  final String error;
  PastJobDetailsError(this.error);
}

class PastJobDetailsQueryError extends PastJobDetailsState {
  final String error;
  PastJobDetailsQueryError(this.error);
}
