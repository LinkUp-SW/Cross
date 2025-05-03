import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'dart:convert';
import 'dart:developer';

class NewChatService {
  final BaseService _baseService = BaseService();

  // Create a new chat conversation
  Future<Map<String, dynamic>> createNewChat(String userId) async {
    try {
      log('Creating new chat with user: $userId');

      // Use the route parameter correctly for this endpoint
      final response = await _baseService.post(
        ExternalEndPoints.startnewchat,
        routeParameters: {
          'user2ID': userId,
        },
        // Empty body or any additional payload if needed
        body: {},
      );

      log('New chat response: ${response.body}');

      if (response.statusCode == 200||response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data == null) {
          throw Exception('Empty response received');
        }

        return data; // Return the full data including conversationId
      } else {
        throw Exception('Failed to start chat: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in createNewChat: $e');
      rethrow;
    }
  }

  // Open an existing chat with a user
  Future<Map<String, dynamic>> openExistingChat(String userId) async {
    try {
      log('Opening existing chat with user: $userId');

      // First, find the conversation ID for this user from the chats list
      final chatsResponse = await fetchChats();
      final List<dynamic> conversations = chatsResponse['conversations'];

      // Find the conversation with this user
      final conversation = conversations.firstWhere(
        (chat) => chat['otherUser']['userId'] == userId,
        orElse: () => null,
      );

      if (conversation == null) {
        throw Exception('No existing conversation found with this user');
      }

      final String conversationId = conversation['conversationId'];

      // Now get the specific conversation with its conversationId
      final response = await _baseService.get(
        ExternalEndPoints.gotospecificchat,
        routeParameters: {
          'conversationId': conversationId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Retrieved conversation data: ${response.body}');
        return data;
      }

      throw Exception('Failed to get conversation: ${response.statusCode}');
    } catch (e) {
      log('Error in openExistingChat: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConnectionsList({
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? routeParameters,
  }) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.connectionsList,
        queryParameters: queryParameters,
        routeParameters: routeParameters,
      );
      log(response.body.toString());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to get connections list: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchChats() async {
    try {
      final baseService = BaseService();
      final response = await baseService.get(ExternalEndPoints.fetchChats);

      if (response.statusCode == 200) {
        log(response.body);
        return jsonDecode(response.body);
      } else {
        log("error: ${response.body}");
        throw Exception("Failed to fetch chats");
      }
    } catch (e) {
      log("error: $e");
      rethrow;
    }
  }
}

final newChatServiceProvider = Provider<NewChatService>((ref) {
  return NewChatService();
});
