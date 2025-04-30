import 'dart:developer';

class Message {
  final String messageId;
  final String senderId;
  final String senderName;
  final String message;
  final List<String> media;
  final DateTime timestamp;
  final String reacted;
  final bool isSeen;
  final bool isOwnMessage;
  final bool?isEdited;

  Message({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.media,
    required this.timestamp,
    this.reacted = '',
    this.isSeen = false,
    this.isOwnMessage=false,
    this.isEdited = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      log('Parsing message - ID: ${json['messageId']}, senderId: ${json['senderId']}, isOwn: ${json['isOwnMessage']}');

      return Message(
        messageId: json['messageId'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        message: json['message'] ?? '',
        media: List<String>.from(json['media'] ?? []),
        timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
        reacted: json['reacted']?.toString() ?? '',
        isSeen: json['isSeen'] ?? false,
        isOwnMessage: json['isOwnMessage'] ?? false,
        isEdited: json['isEdited'] ?? false,
      );
    } catch (e, stackTrace) {
      log('Error parsing message: $json');
      log('Parse error: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'media': media,
      'timestamp': timestamp.toIso8601String(),
      'reacted': reacted,
      'isSeen': isSeen,
      'isOwnMessage': isOwnMessage,
      'isEdited': isEdited,
    };
  }

  bool hasReaction() => reacted.isNotEmpty;
}
