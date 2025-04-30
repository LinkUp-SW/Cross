
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
  final List<dynamic> conversationtype;


  Chat({
    required this.conversationId,
    required this.senderId,
    required this.sendername,
    required this.senderprofilePictureUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.conversationtype
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
      conversationtype:json['conversationType'],
      isOnline: otherUser['onlineStatus'] ?? false,
    );
  }
}
