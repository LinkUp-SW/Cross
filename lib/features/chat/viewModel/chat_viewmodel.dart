import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/services/chat_service.dart';
import 'package:link_up/features/chat/state/chat_state.dart';
import '../model/chat_model.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  final ApiChatService chatService;

  ChatViewModel(this.chatService) : super(ChatState.initial());

  Future<void> fetchChats() async {
    state = state.copyWith(isloading: true, isError: false);
    try {
      final response = await chatService.fetchChats();
      final chats = (response['conversations'] as List).map((chat) => Chat.fromJson(chat)).toList();
      state = state.copyWith(chats: chats, isloading: false, isError: false);
    } catch (e) {
      state = state.copyWith(isloading: false, isError: true);
    }
  }

  Future<void> deleteChat(int index) async {
    try {
      final chat = state.chats![index];
      state = state.copyWith(isloading: true, isError: false);

      final isDeleted = await chatService.deleteChat(chat.conversationId);

      if (isDeleted) {
        final updatedChats = List<Chat>.from(state.chats!);
        updatedChats.removeAt(index);
        state = state.copyWith(
          chats: updatedChats,
          isloading: false,
          isError: false,
        );
      } else {
        state = state.copyWith(
          isloading: false,
          isError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isloading: false,
        isError: true,
      );
    }
  }

/* 
  void updateTypingStatus(int chatIndex, bool isTyping) {
    final chat = state[chatIndex];
    final updatedChat = chat.copyWith(
      isTyping: isTyping,
      typingUser: isTyping ? InternalEndPoints.userId.split("-")[0].toString() : null,
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
    final otherUserName = chat.sendername; // Dynamically get other user's name

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
  } */

  /*   void sendMessage(int chatIndex, String messageContent, MessageType type) {
  final chat = state[chatIndex];
  if (chat.isBlocked) return;

  final newMessage = Message(
    sender: InternalEndPoints.userId.split("-")[0].toString(),
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
int startNewOrOpenExistingChat(ConnectionsCardModel connection) {
  final existingIndex = state.indexWhere((chat) => chat.senderId == connection.cardId);
  if (existingIndex != -1) {
    return existingIndex;
  }

  final newChat = Chat(

    senderId: connection.cardId,
    sendername: '${connection.firstName} ${connection.lastName}',
    senderprofilePictureUrl: connection.profilePicture, 
    messages: [],
    isUnread: false,
    isTyping: false,
    isBlocked: false,
    lastMessage: "",
    lastMessageTimestamp: DateTime.now(),
    unreadMessageCount: 0,
  );

  state = [...state, newChat];
  return state.length - 1;
}
 */
/* 
  void _updateLastMessageStatus(int chatIndex, DeliveryStatus status) {
  final chat = state[chatIndex];
  final messages = chat.messages;
  if (messages.isEmpty) return;

  // Find the last message sent by the current user (jumana)
  final lastMessageIndex = messages.lastIndexWhere(
    (message) => message.sender == InternalEndPoints.userId.split("-")[0].toString(),
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
 */

/* 
  void sendMediaAttachment(int chatIndex, String mediaUrl, MessageType type) {
    final chat = state[chatIndex];
    if (chat.isBlocked) return;

    final newMessage = Message(
      sender: InternalEndPoints.userId.split("-")[0].toString(),
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
  } */

  /* 

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
  } */
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return ChatViewModel(chatService);
});
