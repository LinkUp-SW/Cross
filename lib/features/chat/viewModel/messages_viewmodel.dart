import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/message_model.dart';
import '../services/messages_service.dart';
import '../state/messages_state.dart';

class MessagesViewModel extends StateNotifier<MessagesState> {
  final MessagesService _service;
  final String conversationId;

  MessagesViewModel({
    required MessagesService service,
    required this.conversationId,
  })  : _service = service,
        super(MessagesState.initial());

  /* Future<void> sendMessage(String content, List<String> media) async {
    try {
      state = state.copyWith(isSending: true, isError: false);

      // Call the MessagesService with content and media
      final message = await _service.sendMessage(
        conversationId: conversationId,
        content: content,
        media: media,
      );

      // Add the new message to the current message list
      final updatedMessages = [...state.messages ?? [], message];

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        isError: false,
      );

      // Simulate delivery and read status updates
      await Future.delayed(const Duration(seconds: 1));
      _updateMessageDeliveryStatus(message.messageId, DeliveryStatus.delivered);

      await Future.delayed(const Duration(seconds: 1));
      _updateMessageDeliveryStatus(message.messageId, DeliveryStatus.read);
    } catch (e) {
      log('Error sending message: $e');
      state = state.copyWith(
        isSending: false,
        isError: true,
      );
      rethrow; // Pass error to UI
    }
  } */

  /* void _updateMessageDeliveryStatus(String messageId, DeliveryStatus status) {
    if (state.messages == null) return;

    final updatedMessages = state.messages!.map((message) {
      if (message.id == messageId) {
        return message.copyWith(deliveryStatus: status);
      }
      return message;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  } */

  /* Future<void> sendMediaAttachment(String mediaUrl, MessageType type) async {
    try {
      state = state.copyWith(isSending: true);

      final message = await _service.sendMessage(
        conversationId: conversationId,
        content: mediaUrl,
      );

      final updatedMessages = [...state.messages ?? [], message];

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        isError: true,
      );
      log('Error sending media: $e');
    }
  }
 */
  Future<void> loadMessages() async {
    try {
      state = state.copyWith(isLoading: true, isError: false);
      log('Loading messages for conversation: $conversationId');

      final messages = await _service.openExistingChat(conversationId);

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        isError: false,
      );

      log('Loaded ${messages.length} messages');
    } catch (e) {
      log('Error loading messages: $e');
      state = state.copyWith(
        isLoading: false,
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final messagesViewModelProvider = StateNotifierProvider.family<MessagesViewModel, MessagesState, String>(
  (ref, conversationId) => MessagesViewModel(
    service: ref.watch(messageServiceProvider),
    conversationId: conversationId,
  ),
);
