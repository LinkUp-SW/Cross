
// fetch all chats
class Chat {
  final String conversationId;
  final String senderId;
  final String sendername;
  final String senderprofilePictureUrl;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final bool isOnline;

  Chat({
    required this.conversationId,
    required this.senderId,
    required this.sendername,
    required this.senderprofilePictureUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    required this.isOnline,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final otherUser = json['otherUser'];
    final lastMessage = json['lastMessage'];

    return Chat(
      conversationId: json['conversationId'],
      senderId: otherUser['userId'],
      sendername: '${otherUser['firstName']} ${otherUser['lastName']}',
      senderprofilePictureUrl: otherUser['profilePhoto'] ?? '',
      lastMessage: lastMessage['message'],
      lastMessageTimestamp: DateTime.parse(lastMessage['timestamp']),
      unreadCount: json['unreadCount'],
      isOnline: otherUser['onlineStatus'] ?? false,
    );
  }
}
