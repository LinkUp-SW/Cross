import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import '../model/message_model.dart';

class MessagesService {
  final BaseService _baseService = BaseService();

  Future<List<Message>> openExistingChat(String conversationId) async {
    try {
      log('Opening chat with ID: $conversationId');
      final endpoint = ExternalEndPoints.gotospecificchat
          .replaceAll(':conversationId', conversationId);

      log('Making request to endpoint: $endpoint');

      final response = await _baseService.get(
        endpoint,
        queryParameters: {'conversationId': conversationId},
      );

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['messages'] != null) {
          final messages = (data['messages'] as List).map((messageJson) {
            // Add isOwnMessage flag based on senderId
            messageJson['isOwnMessage'] = messageJson['senderId'] == 'testUserId';
            log('Processing message: ${messageJson['senderId']} isOwn: ${messageJson['isOwnMessage']}');
            return Message.fromJson(messageJson);
          }).toList();

          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          log('Successfully loaded ${messages.length} messages');
          log('Own messages count: ${messages.where((m) => m.isOwnMessage == true).length}');
          return messages;
        } else {
          log('No messages found in response: $data');
          return [];
        }
      } else {
        log('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      log('Error loading messages: $e');
      log('Stack trace: $stackTrace');
      return [];
    }
  }
}

final messageServiceProvider = Provider<MessagesService>((ref) {
  return MessagesService();
});
