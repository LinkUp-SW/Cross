import '../model/chat_model.dart';

class ChatState {
  final List<Chat>? chats;
  final bool isloading;
  final bool isError;
  final int unreadCount;

  
  const ChatState({required this.chats, this.isloading = true, this.isError = false,  this.unreadCount =0});

  factory ChatState.initial() {
    return const ChatState(chats: [], isloading: true, isError: false);
  }

  ChatState copyWith({
    List<Chat>? chats,
    bool? isloading,
    bool? isError,
    int? unreadCount,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      isloading: isloading ?? this.isloading,
      isError: isError ?? this.isError,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
  
}
