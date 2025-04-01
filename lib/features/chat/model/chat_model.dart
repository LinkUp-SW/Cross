class Chat {
  final String name;
  final String lastMessage;
  final String timestamp;
  bool isUnread;
  final String profilePictureUrl;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.isUnread = true,
    required this.profilePictureUrl,
  });

  // Add a copyWith method to create a modified instance
  Chat copyWith({
    String? name,
    String? lastMessage,
    String? timestamp,
    bool? isUnread,
    String? profilePictureUrl,
  }) {
    return Chat(
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      isUnread: isUnread ?? this.isUnread,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
