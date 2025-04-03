import '../model/chat_model.dart';

class ChatService {
  // Simulate fetching chats from a backend
  Future<List<Chat>> fetchChats() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    // Return mock chat data
    return [
      Chat(
        name: "John Doe",
        lastMessage: "Hello, how are you?",
        lastMessageTimestamp: DateTime.now().subtract(Duration(minutes: 30)),
        isUnread: true,
        profilePictureUrl: "https://example.com/profile1.jpg",
        unreadMessageCount: 2,
        messages: [
          Message(
            sender: "John Doe",
            content: "Hey!",
            timestamp: DateTime.now().subtract(Duration(minutes: 35)),
          ),
          Message(
            sender: "Me",
            content: "Hello, how are you?",
            timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          ),
        ],
      ),
      Chat(
        name: "Jane Smith",
        lastMessage: "Can we reschedule the meeting?",
        lastMessageTimestamp: DateTime.now().subtract(Duration(days: 1, hours: 3)),
        isUnread: false,
        profilePictureUrl: "https://example.com/profile2.jpg",
        unreadMessageCount: 0,
        messages: [
          Message(
            sender: "Jane Smith",
            content: "Can we reschedule the meeting?",
            timestamp: DateTime.now().subtract(Duration(days: 1, hours: 3)),
          ),
          Message(
            sender: "Me",
            content: "Sure, what time works for you?",
            timestamp: DateTime.now().subtract(Duration(days: 1, hours: 4)),
          ),
        ],
      ),
      Chat(
        name: "Alice Johnson",
        lastMessage: "Let’s catch up soon!",
        lastMessageTimestamp: DateTime.now().subtract(Duration(hours: 2)),
        isUnread: true,
        profilePictureUrl: "https://example.com/profile3.jpg",
        unreadMessageCount: 1,
        messages: [
          Message(
            sender: "Alice Johnson",
            content: "Let’s catch up soon!",
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
          ),
          Message(
            sender: "Me",
            content: "Yeah, let’s do it!",
            timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
          ),
        ],
      ),
    ];
  }
}
