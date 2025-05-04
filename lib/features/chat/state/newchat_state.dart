import 'package:link_up/features/chat/model/chat_model.dart';
import 'package:link_up/features/chat/model/connections_chat_model.dart';



class NewChatState {
  final List<ConnectionsChatModel>? connections;
  final bool isLoading;
  final bool isError;
  final List<Chat>? chats;

  const NewChatState({
    required this.connections,
    this.isLoading = true,
    this.isError = false,
    this.chats,
  });

  factory NewChatState.initial() {
    return const NewChatState(connections: [], isLoading: true, isError: false, chats: []);
  }

  NewChatState copyWith({
    List<ConnectionsChatModel>? connections,
    bool? isLoading,
    bool? isError,
    List<Chat>? chats,
  }) {
    return NewChatState(
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      chats: chats ?? this.chats,
    );
  }
}
