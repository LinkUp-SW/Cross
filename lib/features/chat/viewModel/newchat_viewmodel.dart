import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/model/chat_model.dart';
import 'package:link_up/features/chat/model/connections_chat_model.dart';
import '../state/newchat_state.dart';
import '../services/newchat_service.dart'; // service for fetching connections

class NewChatViewModel extends StateNotifier<NewChatState> {
  final NewChatService service;

  NewChatViewModel(this.service) : super(NewChatState.initial());

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

  Future<Map<String, dynamic>> openExistingChat(String userId) async {
    try {
      log("Opening existing chat with user ID: $userId");
      final response = await service.openExistingChat(userId);
      
      // Ensure we have a conversationId in the response
      if (!response.containsKey('conversationId')) {
        log("Warning: Missing conversationId in response, attempting to extract from data");
        // Try to extract from various possible locations
        final conversationId = response['conversation']?['conversationId'] ?? 
                               response['_id'] ??
                               '';
                               
        if (conversationId.isEmpty) {
          throw Exception("Could not find conversationId in response");
        }
        
        response['conversationId'] = conversationId;
      }
      
      log("Got chat result: ${response['conversationId']}");
      return response;
    } catch (e) {
      log("Error opening existing chat: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createNewChat(String userId) async {
    try {
      final response = await service.createNewChat(userId);
      log("Successfully created new chat with user: $userId");
      return response;
    } catch (e) {
      log("Error creating new chat: $e");
      rethrow;
    }
  }
  void updateLoading(bool value) {
  state = state.copyWith(isLoading: value);
}
}

final newChatViewModelProvider = StateNotifierProvider<NewChatViewModel, NewChatState>((ref) {
  final service = ref.watch(newChatServiceProvider);
  return NewChatViewModel(service);
});
