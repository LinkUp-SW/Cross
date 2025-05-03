import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

  Future<String> convertFileToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final base64String = base64Encode(bytes);

    // Determine mime type
    String mimeType;
    if (filePath.toLowerCase().endsWith('.jpg') || filePath.toLowerCase().endsWith('.jpeg')) {
      mimeType = 'image/jpeg';
    } else if (filePath.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (filePath.toLowerCase().endsWith('.mp4')) {
      mimeType = 'video/mp4';
    } else if (filePath.toLowerCase().endsWith('.pdf')) {
      mimeType = 'application/pdf';
    } else {
      mimeType = 'application/octet-stream';
    }

    return 'data:$mimeType;base64,$base64String';
  }
}

final messageServiceProvider = Provider<MessagesService>((ref) {
  return MessagesService();
});
