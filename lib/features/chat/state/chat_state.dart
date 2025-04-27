import '../model/chat_model.dart';

class ChatState {
  final List<Chat>? chats;
  final bool isloading;
  final bool isError;
  const ChatState({required this.chats, this.isloading = true, this.isError = false});

  factory ChatState.initial() {
    return const ChatState(chats: [], isloading: true, isError: false);
  }

  ChatState copyWith({
    List<Chat>? chats,
    bool? isloading,
    bool? isError,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      isloading: isloading ?? this.isloading,
      isError: isError ?? this.isError,
    );
  }
  
}
