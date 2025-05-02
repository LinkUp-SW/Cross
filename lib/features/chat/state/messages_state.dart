import '../model/message_model.dart';

class MessagesState {
  final List<Message>? messages;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  MessagesState({
    this.messages,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  factory MessagesState.initial() => MessagesState(
        messages: [],
        isLoading: false,
        isError: false,
      );

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
