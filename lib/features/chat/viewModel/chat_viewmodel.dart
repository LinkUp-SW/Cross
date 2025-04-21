import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/services/chat_service.dart';
import 'package:link_up/features/chat/services/mock_service.dart';
import '../model/chat_model.dart';

class ChatViewModel extends StateNotifier<List<Chat>> {
  final ChatService _chatService;
  Timer? _typingTimer;

  ChatViewModel(this._chatService) : super([]) {
    _fetchChats();
  }

  void _fetchChats() async {
    state = await _chatService.fetchChats();
  }

  void updateTypingStatus(int chatIndex, bool isTyping) {
    final chat = state[chatIndex];
    final updatedChat = chat.copyWith(
      isTyping: isTyping,
      typingUser: isTyping ? "jumana" : null,
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == chatIndex) updatedChat else state[i],
    ];

    _typingTimer?.cancel();

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 5), () {
        updateTypingStatus(chatIndex, false);
      });
    }
  }

  void simulateOtherUserTyping(int chatIndex) {
    final chat = state[chatIndex];
    final otherUserName = chat.name; // Dynamically get other user's name

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == chatIndex)
          state[i].copyWith(isTyping: true, typingUser: otherUserName)
        else
          state[i]
    ];

    Future.delayed(const Duration(seconds: 3), () {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == chatIndex)
            state[i].copyWith(isTyping: false, typingUser: null)
          else
            state[i]
      ];
    });
  }

    void sendMessage(int chatIndex, String messageContent, MessageType type) {
  final chat = state[chatIndex];
  if (chat.isBlocked) return;

  final newMessage = Message(
    sender: "jumana",
    content: messageContent,
    timestamp: DateTime.now(),
    type: type,
    deliveryStatus: DeliveryStatus.sent,
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

  // Simulate delivered and read status for the last message sent by the current user
  Future.delayed(const Duration(seconds: 1), () {
    _updateLastMessageStatus(chatIndex, DeliveryStatus.delivered);
  });

  Future.delayed(const Duration(seconds: 2), () {
    _updateLastMessageStatus(chatIndex, DeliveryStatus.read);
  });

  // Simulate the other user typing
  Future.delayed(const Duration(seconds: 1), () {
    simulateOtherUserTyping(chatIndex);
  });
}


  void _updateLastMessageStatus(int chatIndex, DeliveryStatus status) {
  final chat = state[chatIndex];
  final messages = chat.messages;
  if (messages.isEmpty) return;

  // Find the last message sent by the current user (jumana)
  final lastMessageIndex = messages.lastIndexWhere(
    (message) => message.sender == "jumana",
  );

  // If no message is found, return early
  if (lastMessageIndex == -1) return;

  final lastMessage = messages[lastMessageIndex];
  final updatedMessages = List<Message>.from(messages);

  // Update only the last sent message with the new delivery status
  updatedMessages[lastMessageIndex] = lastMessage.copyWith(
    deliveryStatus: status,
  );

  // Update the state with the modified messages, leaving others untouched
  state = [
    for (int i = 0; i < state.length; i++)
      if (i == chatIndex)
        chat.copyWith(messages: updatedMessages)
      else
        state[i],
  ];
}



  void sendMediaAttachment(int chatIndex, String mediaUrl, MessageType type) {
    final chat = state[chatIndex];
    if (chat.isBlocked) return;

    final newMessage = Message(
      sender: "jumana",
      content: mediaUrl,
      timestamp: DateTime.now(),
      type: type,
      deliveryStatus: DeliveryStatus.sent,
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

  void deleteChat(int index) {
    state.removeAt(index);
    state = [...state];
  }

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

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  return MockChatService();
});

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, List<Chat>>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return ChatViewModel(chatService);
});
