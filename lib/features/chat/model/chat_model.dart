enum MessageType { text, image, video, document, sticker }

class Chat {
  final String name;
  final String profilePictureUrl;
  final String lastMessage;
  final bool isUnread;
  final int unreadMessageCount;
  final List<Message> messages;
  final DateTime lastMessageTimestamp;
  final bool isBlocked;

  Chat({
    required this.name,
    required this.profilePictureUrl,
    required this.lastMessage,
    required this.isUnread,
    required this.unreadMessageCount,
    required this.messages,
    required this.lastMessageTimestamp,
    this.isBlocked = false,  // Default value is false (not blocked)
  });

  Chat copyWith({
    String? name,
    String? profilePictureUrl,
    String? lastMessage,
    bool? isUnread,
    int? unreadMessageCount,
    List<Message>? messages,
    DateTime? lastMessageTimestamp,
     bool? isBlocked, 
  }) {
    return Chat(
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      isUnread: isUnread ?? this.isUnread,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      messages: messages ?? this.messages,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      isBlocked: isBlocked ?? this.isBlocked,  
    );
  }
}

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}
