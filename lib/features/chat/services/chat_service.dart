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
        timestamp: "10:30 AM",
        isUnread: true,
        profilePictureUrl: "https://example.com/profile1.jpg",
        unreadMessageCount: 2,
      ),
      Chat(
        name: "Jane Smith",
        lastMessage: "Can we reschedule the meeting?",
        timestamp: "Yesterday",
        isUnread: false,
        profilePictureUrl: "https://example.com/profile2.jpg",
        unreadMessageCount: 0,
      ),
      Chat(
        name: "Alice Johnson",
        lastMessage: "Let’s catch up soon!",
        timestamp: "10:00 AM",
        isUnread: true,
        profilePictureUrl: "https://example.com/profile3.jpg",
        unreadMessageCount: 1,
      ),
    ];
  }
}