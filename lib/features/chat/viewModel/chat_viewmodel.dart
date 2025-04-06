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

  final newMessage = Message(
    sender: "Me", 
    content: messageContent, // Content is the text or the media URL
    timestamp: DateTime.now(),
    type: type, // Pass the message type (text, image, video, document)
  );

  state = [
    for (int i = 0; i < state.length; i++)
      if (i == chatIndex)
        state[i].copyWith(
          messages: [...chat.messages, newMessage], // Add new message
          lastMessage: messageContent, // Update last message
          lastMessageTimestamp: DateTime.now(), // Update timestamp
          isUnread: false, // Mark chat as read when you send a message
          unreadMessageCount: 0, // Reset unread count
        )
      else
        state[i], // Keep other chats unchanged
  ];
 }
 
 // Delete a chat from the list
  void deleteChat(int index) {
    state.removeAt(index);
    state = [...state]; // Trigger a rebuild of the list
  }

  // Block a user by marking the chat as blocked
  void blockUser(int index) {
    state[index] = state[index].copyWith(isBlocked: true);
    state = [...state]; // Trigger a rebuild of the list
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
            unreadMessageCount: chat.isUnread ? 0 : -1, // If currently unread → set count to 0 (mark as read), else set to -1 (show blue dot only)
          )
        else
          state[i], // Keep other chats unchanged
    ];
  }
  

}


final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, List<Chat>>((ref) {
  return ChatViewModel(ChatService());
});
