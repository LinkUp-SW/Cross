enum MessageType { text, image, video, document }
enum DeliveryStatus { sent, delivered, read }
class Chat {
  final String name;
  final String profilePictureUrl;
  final String lastMessage;
  final bool isUnread;
  final int unreadMessageCount;
  final List<Message> messages;
  final DateTime lastMessageTimestamp;
  final bool isBlocked;
  bool isTyping = false; 
   final String? typingUser;
  

  Chat({
    required this.name,
    required this.profilePictureUrl,
    required this.lastMessage,
    required this.isUnread,
    required this.unreadMessageCount,
    required this.messages,
    required this.lastMessageTimestamp,
    this.isBlocked = false,  // Default value is false (not blocked)
    this.isTyping = false, 
    this.typingUser, // 
    
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
    bool? isTyping,
    String? typingUser, //
     
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
      isTyping: isTyping ?? this.isTyping, 
         typingUser: typingUser ?? this.typingUser, );
      
  }
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