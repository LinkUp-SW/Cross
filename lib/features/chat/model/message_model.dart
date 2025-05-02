import 'dart:developer';

class Message {
  final String messageId;
  final String senderId;
  final String? receiverId;
  final String senderName;
  final String message;
  final List<String> media;
  final DateTime timestamp;
  final String reacted;
  final bool isSeen;

  final bool? isOwnMessage;
  final bool? isEdited;

  Message({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.media,
    required this.timestamp,
    this.reacted = '',
    this.isSeen = false,
    this.isOwnMessage = false,
    this.isEdited = false,
    this.receiverId,
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
        receiverId: json['receiverId'] ?? null,
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
      'receiverId': receiverId,
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

  Message copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? message,
    List<String>? media,
    DateTime? timestamp,
    String? reacted,
    bool? isSeen,
    bool? isOwnMessage,
    bool? isEdited,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      media: media ?? this.media,
      timestamp: timestamp ?? this.timestamp,
      reacted: reacted ?? this.reacted,
      isSeen: isSeen ?? this.isSeen,
      isOwnMessage: isOwnMessage ?? this.isOwnMessage,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
