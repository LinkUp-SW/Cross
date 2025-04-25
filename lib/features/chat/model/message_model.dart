enum MessageType { text, image, video, document }
enum DeliveryStatus { sent, delivered, read }

MessageType messageTypeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'text':
      return MessageType.text;
    case 'image':
      return MessageType.image;
    case 'video':
      return MessageType.video;
    case 'document':
      return MessageType.document;
    default:
      return MessageType.text;
  }
}

String messageTypeToString(MessageType type) {
  return type.toString().split('.').last;
}

DeliveryStatus deliveryStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'sent':
      return DeliveryStatus.sent;
    case 'delivered':
      return DeliveryStatus.delivered;
    case 'read':
      return DeliveryStatus.read;
    default:
      return DeliveryStatus.sent;
  }
}

String deliveryStatusToString(DeliveryStatus status) {
  return status.toString().split('.').last;
}

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final DeliveryStatus deliveryStatus;

  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.deliveryStatus,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: messageTypeFromString(json['type']),
      deliveryStatus: deliveryStatusFromString(json['deliveryStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': messageTypeToString(type),
      'deliveryStatus': deliveryStatusToString(deliveryStatus),
    };
  }

  Message copyWith({
    String? sender,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    DeliveryStatus? deliveryStatus,
  }) {
    return Message(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
