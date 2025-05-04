import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/services/chat_service.dart';
import 'package:link_up/features/chat/state/chat_state.dart';
import '../model/chat_model.dart';
import 'dart:developer';
import 'package:link_up/features/chat/services/global_socket_service.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  final ApiChatService chatService;
  final GlobalSocketService _globalSocket = GlobalSocketService();
  Timer? _refreshDebouncer;

  ChatViewModel(this.chatService) : super(ChatState.initial()) {
    // Set up socket listener for new messages
    _setupSocketListener();
  }

  void _setupSocketListener() {
    // Listen for new messages to update chat list
    _globalSocket.on('private_message', _handleNewMessage);
    _globalSocket.on('new_message', _handleNewMessage);
    _globalSocket.on('message_sent', _handleNewMessage);
    // Add this new listener for local events
    _globalSocket.on('local_message_sent', _handleLocalMessageSent);
    // Add this listener for unread count updates
    _globalSocket.on('unread_count_update', _handleUnreadCountUpdate);
    log('[CHAT_VIEWMODEL] Set up socket listeners for chat list updates');
  }

  void updateChatLastMessage(
      String conversationId, String messageContent, DateTime timestamp) {
    if (state.chats == null) return;

    final updatedChats = List<Chat>.from(state.chats!);
    final index = updatedChats
        .indexWhere((chat) => chat.conversationId == conversationId);

    if (index != -1) {
      // Create a new chat object with updated properties
      final updatedChat = Chat(
        conversationId: updatedChats[index].conversationId,
        senderId: updatedChats[index].senderId,
        sendername: updatedChats[index].sendername,
        senderprofilePictureUrl: updatedChats[index].senderprofilePictureUrl,
        lastMessage: messageContent,
        lastMessageTimestamp: timestamp,
        unreadCount: updatedChats[index].unreadCount,
        isOnline: updatedChats[index].isOnline,
        conversationtype: updatedChats[index].conversationtype,
      );

      // Remove the chat and reinsert it at the top of the list
      updatedChats.removeAt(index);
      updatedChats.insert(0, updatedChat);

      // Update the state with the modified list
      state = state.copyWith(
        chats: updatedChats,
        isloading: false,
        isError: false,
      );

      log('[CHAT_VIEWMODEL] Instantly updated chat: $conversationId with message: $messageContent');
    }
  }

  void incrementUnreadCount(String conversationId) {
    if (state.chats == null) return;

    final updatedChats = List<Chat>.from(state.chats!);
    final index = updatedChats
        .indexWhere((chat) => chat.conversationId == conversationId);

    if (index != -1) {
      // Create a new chat object with incremented unread count
      final updatedChat = updatedChats[index].copyWith(
        unreadCount: updatedChats[index].unreadCount + 1,
      );

      // Update the chat in the list
      updatedChats[index] = updatedChat;

      // Update the state with the modified list
      state = state.copyWith(
        chats: updatedChats,
        unreadCount:
            state.unreadCount + 1, // Also update the total unread count
      );

      log('[CHAT_VIEWMODEL] Incremented unread count for conversation: $conversationId');
    }
  }

  void _handleNewMessage(dynamic data) {
    try {
      // Extract necessary information from the message
      String? conversationId;
      String? messageContent;
      String? senderId;
      DateTime timestamp = DateTime.now();

      if (data is Map) {
        conversationId = data['conversationId'];
        senderId = data['senderId'];

        // Try to extract message content
        if (data.containsKey('message')) {
          if (data['message'] is String) {
            messageContent = data['message'];
          } else if (data['message'] is Map) {
            messageContent = data['message']['message'] ?? '';
          }
        }

        // Try to parse timestamp
        if (data.containsKey('timestamp')) {
          timestamp = DateTime.tryParse(data['timestamp']) ?? timestamp;
        }
      }

      // If we have the necessary data, update the chat
      if (conversationId != null && messageContent != null) {
        updateChatLastMessage(conversationId, messageContent, timestamp);

        // Only increment unread count if the message is from someone else
        if (senderId != null && senderId != InternalEndPoints.userId) {
          incrementUnreadCount(conversationId);
        }
      } else {
        // Fall back to full refresh if we can't extract the necessary data
        fetchChats();
      }
    } catch (e) {
      log('[CHAT_VIEWMODEL] Error processing message update: $e');
      fetchChats();
    }
  }

  void _handleLocalMessageSent(dynamic data) {
    try {
      if (data is Map &&
          data.containsKey('conversationId') &&
          data.containsKey('message')) {
        final conversationId = data['conversationId'];
        final messageContent = data['message'];
        final timestamp =
            DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now();

        // Immediately update the chat list with this message
        updateChatLastMessage(conversationId, messageContent, timestamp);
      }
    } catch (e) {
      log('[CHAT_VIEWMODEL] Error handling local message update: $e');
    }
  }

  void _handleUnreadCountUpdate(dynamic data) {
    try {
      if (data is Map &&
          data.containsKey('conversationId') &&
          data.containsKey('unreadCount')) {
        final conversationId = data['conversationId'];
        final unreadCount = data['unreadCount'];

        // Update the specific chat's unread count
        if (state.chats == null) return;

        final updatedChats = List<Chat>.from(state.chats!);
        final index = updatedChats
            .indexWhere((chat) => chat.conversationId == conversationId);

        if (index != -1) {
          final difference = unreadCount - updatedChats[index].unreadCount;
          final updatedChat =
              updatedChats[index].copyWith(unreadCount: unreadCount);
          updatedChats[index] = updatedChat;

          state = state.copyWith(
            chats: updatedChats,
            unreadCount: (state.unreadCount + difference.toInt()) as int?,
          );

          log('[CHAT_VIEWMODEL] Updated unread count for conversation $conversationId to $unreadCount');
        }
      }
    } catch (e) {
      log('[CHAT_VIEWMODEL] Error handling unread count update: $e');
    }
  }

  @override
  void dispose() {
    // Clean up socket listeners when viewmodel is disposed
    _globalSocket.off('private_message', _handleNewMessage);
    _globalSocket.off('new_message', _handleNewMessage);
    _globalSocket.off('message_sent', _handleNewMessage);
    _globalSocket.off(
        'local_message_sent', _handleLocalMessageSent); // Add this
    _globalSocket.off(
        'unread_count_update', _handleUnreadCountUpdate); // Add this
    _refreshDebouncer?.cancel();
    super.dispose();
  }

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

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return ChatViewModel(chatService);
});
