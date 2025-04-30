import '../model/message_model.dart';

class MessagesState {
  final List<Message>? messages;
  final bool isLoading;
  final bool isError;
  final bool isSending;

  const MessagesState({
    required this.messages,
    this.isLoading = true,
    this.isError = false,
    this.isSending = false,
  });

  factory MessagesState.initial() {
    return const MessagesState(messages: [], isLoading: true, isError: false, isSending: false);
  }

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isError,
    bool? isSending,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSending: isSending ?? this.isSending,
    );
  }
}
