import 'message_model.dart';

class Chat {
  final String userId;
  final String name;
  final String profilePictureUrl;
  final String lastMessage;
  final bool isUnread;
  final int unreadMessageCount;
  final List<Message> messages;
  final DateTime lastMessageTimestamp;
  final bool isBlocked;
  bool isTyping;
  final String? typingUser;

  Chat({
    required this.userId,
    required this.name,
    required this.profilePictureUrl,
    required this.lastMessage,
    required this.isUnread,
    required this.unreadMessageCount,
    required this.messages,
    required this.lastMessageTimestamp,
    this.isBlocked = false,
    this.isTyping = false,
    this.typingUser,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      userId: json['userId'],
      name: json['name'],
      profilePictureUrl: json['profilePictureUrl'],
      lastMessage: json['lastMessage'],
      isUnread: json['isUnread'],
      unreadMessageCount: json['unreadMessageCount'],
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e))
          .toList(),
      lastMessageTimestamp: DateTime.parse(json['lastMessageTimestamp']),
      isBlocked: json['isBlocked'] ?? false,
      isTyping: json['isTyping'] ?? false,
      typingUser: json['typingUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'lastMessage': lastMessage,
      'isUnread': isUnread,
      'unreadMessageCount': unreadMessageCount,
      'messages': messages.map((e) => e.toJson()).toList(),
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'isBlocked': isBlocked,
      'isTyping': isTyping,
      'typingUser': typingUser,
    };
  }

  Chat copyWith({
    String? name,
    String? profilePictureUrl,
    String? lastMessage,
    bool? isUnread,
    int? unreadMessageCount,
    List<Message>? messages,
    DateTime? lastMessageTimestamp,
    bool? isBlocked,
    bool? isTyping,
    String? typingUser,
  }) {
    return Chat(
      userId: userId,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      isUnread: isUnread ?? this.isUnread,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      messages: messages ?? this.messages,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      isBlocked: isBlocked ?? this.isBlocked,
      isTyping: isTyping ?? this.isTyping,
      typingUser: typingUser ?? this.typingUser,
    );
  }
}
