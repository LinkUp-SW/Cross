class Chat {
  final String name;
  final String lastMessage;
  final String timestamp;
  final bool isUnread;
  final String profilePictureUrl;
  final int unreadMessageCount;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.isUnread,
    required this.profilePictureUrl,
    required this.unreadMessageCount,
  });

  //  copyWith method to update properties immutably
  Chat copyWith({
    String? name,
    String? lastMessage,
    String? timestamp,
    bool? isUnread,
    String? profilePictureUrl,
    int? unreadMessageCount,
  }) {
    return Chat(
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      isUnread: isUnread ?? this.isUnread,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
    );
  }
}
