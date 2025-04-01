import '../model/chat_model.dart';

class ChatService {
  Future<List<Chat>> fetchChats() async {
    // Mock data for now
    return [
      Chat(
        name: 'John Doe',
        lastMessage: 'Hey, how are you?',
        timestamp: '2:30 PM',
        isUnread: true,
        profilePictureUrl: 'https://example.com/john.jpg',
      ),
      Chat(
        name: 'Jane Smith',
        lastMessage: 'Lets meet up tomorrow.',
        timestamp: '1:45 PM',
        isUnread: false,
        profilePictureUrl: 'https://example.com/jane.jpg',
      ),
      // Add more mock chats here
    ];
  }
}
