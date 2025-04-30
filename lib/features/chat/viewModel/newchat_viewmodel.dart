import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/model/chat_model.dart';
import 'package:link_up/features/chat/model/connections_chat_model.dart';
import 'package:link_up/features/my-network/model/connections_screen_model.dart';
import '../state/newchat_state.dart';
import '../services/newchat_service.dart'; // service for fetching connections

class NewChatViewModel extends StateNotifier<NewChatState> {
  final NewChatService service;

  NewChatViewModel(this.service) : super(NewChatState.initial());

  /* Future<Chat> startNewOrOpenExistingChat(ConnectionsCardModel connection) async {
    try {
      state = state.copyWith(isLoading: true, isError: false);

      // Check if chat already exists with this connection
      final existingChat = state.connections?.firstWhere(
        (conn) => conn.cardId == connection.cardId,
         orElse: () = 
      );

      if (existingChat != null) {
        // Open existing chat
        final chat = await service.openExistingChat(existingChat.conversationId);
        state = state.copyWith(isLoading: false);
        return chat;
      } else {
        // Start new chat
        final chat = await service.startnewchat(connection.cardId);
        state = state.copyWith(isLoading: false);
        return chat;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
      throw Exception('Failed to start or open chat: $e');
    }
  }  */

  Future<void> fetchChats() async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final response = await service.fetchChats();
      final chats = (response['conversations'] as List).map((chat) => Chat.fromJson(chat)).toList();
      log(chats.toString());

      state = state.copyWith(chats: chats, isLoading: false, isError: false);

      // Filter connections after fetching chats
      filterConnections();
    } catch (e) {
      log("Error fetching chats: $e");
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> getConnectionsList(Map<String, dynamic>? queryParameters) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final userId = InternalEndPoints.userId;
      final response = await service.getConnectionsList(
        queryParameters: queryParameters,
        routeParameters: {'user_id': userId},
      );

      final List<ConnectionsChatModel> connections =
          (response['connections'] as List).map((connection) => ConnectionsChatModel.fromJson(connection)).toList();

      state = state.copyWith(connections: connections, isLoading: false);

      // Filter connections after fetching them
      filterConnections();
    } catch (e) {
      log("Error fetching connections: $e");
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  void filterConnections() {
    try {
      if (state.connections == null || state.chats == null) {
        log("Either connections or chats list is null");
        return;
      }

      final updatedConnections = state.connections!.map((connection) {
        // Check if this connection has an existing chat
        final hasExistingChat = state.chats!.any((chat) => chat.senderId == connection.cardId);

        // Create new connection with updated isExistingChat value
        return ConnectionsChatModel(
          cardId: connection.cardId,
          firstName: connection.firstName,
          lastName: connection.lastName,
          title: connection.title,
          profilePicture: connection.profilePicture,
          connectionDate: connection.connectionDate,
          isExistingChat: hasExistingChat,
        );
      }).toList();

      log("Filtered connections. Found $updatedConnections");

      // Update state with filtered connections
      state = state.copyWith(
        connections: updatedConnections,
        isLoading: false,
        isError: false,
      );
    } catch (e) {
      log("Error filtering connections: $e");
      state = state.copyWith(isError: true);
    }
  }
}

final newChatViewModelProvider = StateNotifierProvider<NewChatViewModel, NewChatState>((ref) {
  final service = ref.watch(newChatServiceProvider);
  return NewChatViewModel(service);
});
