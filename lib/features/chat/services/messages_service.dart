import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../model/message_model.dart';

class MessagesService {
  final BaseService _baseService = BaseService();
  late IO.Socket socket;

  Future<List<Message>> openExistingChat(String conversationId) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.gotospecificchat.replaceAll(':conversationId', conversationId),
        queryParameters: {
          'conversationId': conversationId,
          'limit': '100',
          'includeNewMessages': 'true',
          'timestamp': DateTime.now().toIso8601String(), // Add timestamp for fresh data
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List).map((msg) => Message.fromJson(msg)).toList();
        log('[SERVICE] Loaded ${messages.length} messages from server');
        return messages;
      }

      throw Exception('Failed to load messages: ${response.statusCode}');
    } catch (e) {
      log('[SERVICE] Error loading messages: $e');
      rethrow;
    }
  }
}

final messageServiceProvider = Provider<MessagesService>((ref) {
  return MessagesService();
});
