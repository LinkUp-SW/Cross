class Chat {
  final String name;
  final String lastMessage;
  final String timestamp;
  final bool isUnread;
  final String profilePictureUrl;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.isUnread,
    required this.profilePictureUrl,
  });
}
