import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/chat_model.dart';

class ChatState extends StateNotifier<List<Chat>> {
  ChatState() : super([]);

  // Load the chats (mock data)
  Future<void> loadChats(List<Chat> chats) async {
    state = chats;
  }

  // Toggle read/unread status (Only mark unread as read)
  void markAsRead(int index) {
    if (index >= 0 && index < state.length && state[index].isUnread) {
      state = [
        ...state.sublist(0, index),
        state[index].copyWith(isUnread: false),
        ...state.sublist(index + 1),
      ];
    }
  }
}

// Riverpod provider for ChatState
final chatStateProvider = StateNotifierProvider<ChatState, List<Chat>>(
  (ref) => ChatState(),
);
