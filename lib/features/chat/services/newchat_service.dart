import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/chat/model/chat_model.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:link_up/features/chat/model/message_model.dart';

class NewChatService {
  BaseService _baseService = BaseService();

  Future<Chat> startnewchat(String userId) async {
    try {
      log('Starting new chat with user: $userId');

      final response = await _baseService.post(
        ExternalEndPoints.startnewchat,
        body: {
          // Changed from routeParameters to body
          'user2ID': userId,
        },
      );

      log('New chat response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null) {
          throw Exception('Empty response received');
        }

        if (!data.containsKey('conversation')) {
          throw Exception('No conversation data in response');
        }

        return Chat.fromJson(data['conversation']);
      } else {
        throw Exception('Failed to start chat: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in startnewchat: $e');
      rethrow;
    }
  }

  Future<List<Message>> openExistingChat(String conversationId) async {
    try {
      log('Opening existing chat: $conversationId');
      final endpoint = ExternalEndPoints.gotospecificchat.replaceAll(':conversationId', conversationId);

      final response = await _baseService.post(endpoint);
      log('Open chat response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || !data.containsKey('messages')) {
          throw Exception('Invalid response format');
        }

        final messagesList = data['messages'] as List;
        final messages = messagesList.map((messageJson) {
          messageJson['isOwnMessage'] = messageJson['senderId'] == InternalEndPoints.userId;
          return Message.fromJson(messageJson);
        }).toList();

        log('Successfully loaded ${messages.length} messages');
        return messages;
      } else {
        throw Exception('Failed to open chat: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error opening chat: $e');
      log('Stack trace: $stackTrace');
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
