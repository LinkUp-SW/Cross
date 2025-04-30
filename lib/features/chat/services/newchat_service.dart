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
      final baseService = BaseService();
      final response = await baseService.post(
        ExternalEndPoints.startnewchat,
        routeParameters: {
          'user2ID': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Chat.fromJson(data['conversation']);
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to start new chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting new chat: $e');
    }
  }

 Future<List<Message>> openExistingChat(String conversationId) async {
    try {
      final baseService = BaseService();
      final endpoint = ExternalEndPoints.gotospecificchat.replaceAll(':conversationId', conversationId);

      final response = await baseService.post(
        endpoint,
         // Empty body since we're using path parameter
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List).map((messageJson) => Message.fromJson(messageJson)).toList();
        return messages;
      } else if (response.statusCode == 404) {
        log('Chat not found: $conversationId');
        throw Exception('Chat not found');
      } else {
        log('Failed to open chat: ${response.statusCode}');
        throw Exception('Failed to open chat: ${response.statusCode}');
      }
    } catch (e) {
      log('Error opening chat: $e');
      throw Exception('Error opening chat: $e');
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
      log (response.body.toString());
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
