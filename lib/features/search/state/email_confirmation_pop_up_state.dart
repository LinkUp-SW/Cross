class EmailConfirmationPopUpState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  const EmailConfirmationPopUpState({
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  EmailConfirmationPopUpState copyWith({
    final bool? isLoading,
    final bool? isError,
    final String? errorMessage,
  }) {
    return EmailConfirmationPopUpState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
