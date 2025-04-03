import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/chat_model.dart';
import '../services/chat_service.dart';

class ChatViewModel extends StateNotifier<List<Chat>> {
  final ChatService _chatService;

  ChatViewModel(this._chatService) : super([]) {
    _fetchChats();
  }

  // Fetch chats from the service
  void _fetchChats() async {
    state = await _chatService.fetchChats();
  }

  // Toggle read/unread status (Only marks as read when tapped)
  void toggleReadUnreadStatus(int index) {
    final chat = state[index];

    // Only mark as read if currently unread
    if (chat.isUnread) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(isUnread: false, unreadMessageCount: 0) // Mark as read
          else
            state[i], // Keep other chats unchanged
      ];
    }
  }

  // Mark chat as read or unread via long press
  void markReadUnread(int index) {
    final chat = state[index];

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(
            isUnread: !state[i].isUnread, // Toggle unread status
            unreadMessageCount: chat.isUnread ? 0 : -1, 
            // If currently unread → set count to 0 (mark as read)
            // If currently read → set count to -1 (show blue dot only)
          )
        else
          state[i],
    ];
  }
}

// Properly defined provider
final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, List<Chat>>((ref) {
  return ChatViewModel(ChatService());
});
