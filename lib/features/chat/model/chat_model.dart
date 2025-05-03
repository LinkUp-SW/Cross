// fetch all chats
import 'dart:developer';

class Chat {
  final String conversationId;
  final String senderId;
  final String sendername;
  final String senderprofilePictureUrl;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final int unreadCount;
  final bool isOnline;
  final List<dynamic> conversationtype;

  Chat({
    required this.conversationId,
    required this.senderId,
    required this.sendername,
    required this.senderprofilePictureUrl,
    this.lastMessage, // Made optional
    this.lastMessageTimestamp, // Made optional
    required this.unreadCount,
    required this.isOnline,
    required this.conversationtype,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    try {
      final otherUser = json['otherUser'] as Map<String, dynamic>;
      // Handle lastMessage that could be empty string, null, or Map
      final dynamic lastMessageData = json['lastMessage'];

      String? lastMessageText;
      DateTime? messageTimestamp;

      if (lastMessageData != null && lastMessageData is Map<String, dynamic>) {
        lastMessageText = lastMessageData['message'] as String?;
        messageTimestamp =
            lastMessageData.containsKey('timestamp') ? DateTime.parse(lastMessageData['timestamp'] as String) : null;
      }

      return Chat(
        conversationId: json['conversationId'] as String,
        senderId: otherUser['userId'] as String,
        sendername: '${otherUser['firstName']} ${otherUser['lastName']}',
        senderprofilePictureUrl: otherUser['profilePhoto'] as String? ?? '',
        lastMessage: lastMessageText,
        lastMessageTimestamp: messageTimestamp,
        unreadCount: json['unreadCount'] as int? ?? 0,
        conversationtype: json['conversationType'] as List<dynamic>? ?? [],
        isOnline: otherUser['onlineStatus'] as bool? ?? false,
      );
    } catch (e, stackTrace) {
      log('Error parsing chat JSON: $json');
      log('Error details: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Add toString for debugging
  @override
  String toString() {
    return 'Chat{conversationId: $conversationId, sendername: $sendername, lastMessage: $lastMessage}';
  }

  Chat copyWith({
    String? conversationId,
    String? senderId,
    String? sendername,
    String? senderprofilePictureUrl,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
    bool? isOnline,
    List<dynamic>? conversationtype,
  }) {
    return Chat(
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sendername: sendername ?? this.sendername,
      senderprofilePictureUrl: senderprofilePictureUrl ?? this.senderprofilePictureUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      conversationtype: conversationtype ?? this.conversationtype,
    );
  }
}
