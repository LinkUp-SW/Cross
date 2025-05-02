import '../model/message_model.dart';

class MessagesState {
  final List<Message>? messages;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final bool isOtherUserTyping; // Add this field

  MessagesState({
    this.messages,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.isOtherUserTyping = false, // Add this parameter
  });

  factory MessagesState.initial() => MessagesState(
        messages: [],
        isLoading: false,
        isError: false,
        isOtherUserTyping: false, // Initialize this field
      );

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    bool? isOtherUserTyping, // Add this parameter
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping, // Use this parameter
    );
  }
}
