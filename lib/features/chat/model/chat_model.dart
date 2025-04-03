class Chat {
  final String name;
  final String profilePictureUrl;
  final String lastMessage;
  final bool isUnread;
  final int unreadMessageCount;
  final List<Message> messages; // List to store messages
  final DateTime lastMessageTimestamp; // Timestamp for the last message in the chat

  Chat({
    required this.name,
    required this.profilePictureUrl,
    required this.lastMessage,
    required this.isUnread,
    required this.unreadMessageCount,
    required this.messages, 
    required this.lastMessageTimestamp, 
  });

  // method to add a new message to the chat
  Chat addMessage(Message newMessage) {
    return Chat(
      name: name,
      profilePictureUrl: profilePictureUrl,
      lastMessage: newMessage.content,
      isUnread: true, // Mark as unread when a new message arrives
      unreadMessageCount: unreadMessageCount + 1,
      messages: [...messages, newMessage], // Add new message to the list
      lastMessageTimestamp: newMessage.timestamp, // Update the last message timestamp
    );
  }

  // Copy with method for immutability
  Chat copyWith({
    String? name,
    String? profilePictureUrl,
    String? lastMessage,
    bool? isUnread,
    int? unreadMessageCount,
    List<Message>? messages,
    DateTime? lastMessageTimestamp,
  }) {
    return Chat(
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      isUnread: isUnread ?? this.isUnread,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      messages: messages ?? this.messages,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
    );
  }
}

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;
  
  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
