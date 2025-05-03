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

  void sendMessage(int chatIndex, String messageContent, MessageType type) {
    final chat = state[chatIndex];

    // Prevent sending if the user is blocked
    if (chat.isBlocked) return;

    final newMessage = Message(
      sender: "jumana",
      content: messageContent,
      timestamp: DateTime.now(),
      type: type,
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == chatIndex)
          state[i].copyWith(
            messages: [...chat.messages, newMessage],
            lastMessage: messageContent,
            lastMessageTimestamp: DateTime.now(),
            isUnread: false,
            unreadMessageCount: 0,
          )
        else
          state[i],
    ];
  }

  void sendMediaAttachment(int chatIndex, String mediaUrl, MessageType type) {
    final chat = state[chatIndex];

    // Prevent sending if the user is blocked
    if (chat.isBlocked) return;

    final newMessage = Message(
      sender: "jumana",
      content: mediaUrl,
      timestamp: DateTime.now(),
      type: type,
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == chatIndex)
          state[i].copyWith(
            messages: [...chat.messages, newMessage],
            lastMessage: "📎 Media Attachment",
            lastMessageTimestamp: DateTime.now(),
            isUnread: false,
            unreadMessageCount: 0,
          )
        else
          state[i],
    ];
  }

  // Delete a chat from the list
  void deleteChat(int index) {
    state.removeAt(index);
    state = [...state]; // Trigger rebuild
  }

  // Block a user → clear messages and mark as blocked
  void blockUser(int index) {
    final chat = state[index];
    final updatedChat = chat.copyWith(
      isBlocked: true,
      messages: [],
      lastMessage: "You blocked this user.",
      lastMessageTimestamp: DateTime.now(),
      unreadMessageCount: 0,
      isUnread: false,
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedChat else state[i],
    ];
  }

  // Optional: Unblock a user (restores ability to chat)
  void unblockUser(int index) {
    final chat = state[index];
    final updatedChat = chat.copyWith(
      isBlocked: false,
      lastMessage: "User unblocked. Start messaging again.",
      lastMessageTimestamp: DateTime.now(),
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedChat else state[i],
    ];
  }

  // Toggle read/unread status (Only marks as read when tapped)
  void toggleReadUnreadStatus(int index) {
    final chat = state[index];

    if (chat.isUnread) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(isUnread: false, unreadMessageCount: 0)
          else
            state[i],
      ];
    }
  }

  // Long press toggle
  void markReadUnread(int index) {
    final chat = state[index];

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(
            isUnread: !state[i].isUnread,
            unreadMessageCount: chat.isUnread ? 0 : -1,
          )
        else
          state[i],
    ];
  }

  void getAllCounts() {}
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, List<Chat>>((ref) {
  return ChatViewModel(ChatService());
});
