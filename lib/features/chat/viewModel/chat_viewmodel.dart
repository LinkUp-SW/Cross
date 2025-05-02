import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/services/chat_service.dart';
import 'package:link_up/features/chat/state/chat_state.dart';
import '../model/chat_model.dart';
import 'dart:developer';

class ChatViewModel extends StateNotifier<ChatState> {
  final ApiChatService chatService;

  ChatViewModel(this.chatService) : super(ChatState.initial());

  Future<void> fetchChats() async {
    try {
      state = state.copyWith(isloading: true, isError: false);

      final response = await chatService.fetchChats();
      log('Raw response: ${response.toString()}');

      if (response == null || !response.containsKey('conversations')) {
        throw Exception('Invalid response format');
      }

      final conversationsList = response['conversations'] as List;
      final List<Chat> chats = [];
      int failedParseCount = 0;

      for (var chatJson in conversationsList) {
        try {
          final chat = Chat.fromJson(chatJson as Map<String, dynamic>);
          chats.add(chat);
        } catch (e) {
          failedParseCount++;
          log('Warning: Failed to parse chat: $e');
          log('Problematic chat data: $chatJson');
          // Continue with next chat instead of failing completely
          continue;
        }
      }

      if (failedParseCount > 0) {
        log('Warning: Failed to parse $failedParseCount chats out of ${conversationsList.length}');
      }

      state = state.copyWith(
        chats: chats,
        isloading: false,
        isError: false,
        unreadCount: response['conversationUnreadCount'] as int? ?? 0,
      );

      log('Successfully loaded ${chats.length} chats');
    } catch (e) {
      log("Error fetching chats: $e");
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

  Future<void> blockUser(int index) async {
    try {
      // Validate index
      if (index < 0 || index >= (state.chats?.length ?? 0)) {
        state = state.copyWith(isError: true);
        return;
      }

      final chat = state.chats![index];
      state = state.copyWith(isloading: true, isError: false);

      // Call block user API
      final isBlocked = await chatService.blockUser(chat.senderId);

      if (isBlocked) {
        final updatedChats = List<Chat>.from(state.chats!);
        updatedChats[index] = Chat(
          conversationId: chat.conversationId,
          senderId: chat.senderId,
          sendername: chat.sendername,
          senderprofilePictureUrl: chat.senderprofilePictureUrl,
          lastMessage: "You blocked this user",
          lastMessageTimestamp: DateTime.now(),
          unreadCount: 0,
          isOnline: false,
          conversationtype: ["blocked"],
        );

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
      log("Error in blockUser: $e");
      state = state.copyWith(
        isloading: false,
        isError: true,
      );
    }
  }

  Future<void> getAllCounts() async {
    try {
      state = state.copyWith(isloading: true, isError: false);

      final response = await chatService.getAllCounts();
      final unread = response['unreadCount'] as int;

      state = state.copyWith(
        isloading: false,
        isError: false,
        unreadCount: unread,
      );

      log("Total unread count: $unread");
    } catch (e) {
      log("Error fetching unread count: $e");
      state = state.copyWith(isloading: false, isError: true);
    }
  }

  Future<void> markChatAsRead(int index) async {
    try {
      if (index < 0 || index >= (state.chats?.length ?? 0)) {
        log("Invalid chat index: $index");
        return;
      }

      final chat = state.chats![index];
      state = state.copyWith(isloading: true, isError: false);

      log("Calling markRead service for chat: ${chat.conversationId}");
      final response = await chatService.markRead(chat.conversationId);

      if (response) {
        // Update the chat list after successful API call
        await fetchChats();
        log("Successfully updated chat read status");
      } else {
        state = state.copyWith(
          isloading: false,
          isError: true,
        );
        log("Failed to mark chat as read");
      }
    } catch (e) {
      log("Error in markChatAsRead: $e");
      state = state.copyWith(
        isloading: false,
        isError: true,
      );
    }
  }

  Future<void> markChatAsUnread(int index) async {
    try {
      if (index < 0 || index >= (state.chats?.length ?? 0)) {
        log("Invalid chat index: $index");
        return;
      }

      final chat = state.chats![index];
      state = state.copyWith(isloading: true, isError: false);

      log("Calling markUnread service for chat: ${chat.conversationId}");
      final response = await chatService.markunRead(chat.conversationId);

      if (response) {
        // Update the chat list after successful API call
        await fetchChats();
        log("Successfully updated chat unread status");
      } else {
        state = state.copyWith(
          isloading: false,
          isError: true,
        );
        log("Failed to mark chat as unread");
      }
    } catch (e) {
      log("Error in markChatAsUnread: $e");
      state = state.copyWith(
        isloading: false,
        isError: true,
      );
    }
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return ChatViewModel(chatService);
});
