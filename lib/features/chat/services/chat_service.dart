import '../model/chat_model.dart';

class ChatService {
  Future<List<Chat>> fetchChats() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    return [
      Chat(
        name: "John Doe",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar2.png",
        lastMessage: "Hello, how are you?",
        isUnread: true,
        unreadMessageCount: 2,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        messages: [
          Message(
              sender: "John Doe",
              content: "Hello, how are you?",
              timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
              type: MessageType.text),
          Message(
              sender: "You",
              content: "I'm good, thanks!",
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              type: MessageType.text),
          Message(
              sender: "John Doe",
              content: "https://www.w3schools.com/w3images/fjords.jpg",
              timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
              type: MessageType.image),
          Message(
              sender: "You",
              content: "https://www.w3schools.com/html/movie.mp4",
              timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              type: MessageType.video), // Real video URL
          Message(
              sender: "John Doe",
              content: "https://www.w3.org/WAI/WCAG21/quickref/files/WCAG21-quickref-2018.pdf",
              timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              type: MessageType.document), // Real PDF document URL
        ],
      ),
      Chat(
        name: "Jane Smith",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar6.png",
        lastMessage: "Check this document",
        isUnread: false,
        unreadMessageCount: 0,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        messages: [
          Message(
              sender: "Jane Smith",
              content: "Check this document",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.text),
          Message(
              sender: "Jane Smith",
              content: "https://www.w3.org/WAI/WCAG21/quickref/files/WCAG21-quickref-2018.pdf",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.document), // Real PDF document URL
        ],
      ),
      Chat(
        name: "Sam Green",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar5.png",
        lastMessage: "Take a look at this presentation",
        isUnread: false,
        unreadMessageCount: 0,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 3)),
        messages: [
          Message(
              sender: "Sam Green",
              content: "Take a look at this presentation",
              timestamp: DateTime.now().subtract(const Duration(days: 3)),
              type: MessageType.text),
          Message(
              sender: "You",
              content: "Here's the link",
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              type: MessageType.text),
          Message(
              sender: "Sam Green",
              content: "https://www.w3.org/WAI/WCAG21/quickref/files/WCAG21-quickref-2018.pdf",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.document), // Real document URL
          Message(
              sender: "You",
              content: "https://www.w3schools.com/html/movie.mp4",
              timestamp: DateTime.now().subtract(const Duration(hours: 5)),
              type: MessageType.video), // Real video URL
        ],
      ),
      Chat(
        name: "Alex Blue",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar4.png", // Real profile picture URL
        lastMessage: "Here's a cool image!",
        isUnread: true,
        unreadMessageCount: 1,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        messages: [
          Message(
              sender: "Alex Blue",
              content: "Here's a cool image!",
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              type: MessageType.text),
          Message(
              sender: "You",
              content: "Check out this picture",
              timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
              type: MessageType.text),
          Message(
              sender: "Alex Blue",
              content: "https://www.w3schools.com/w3images/lights.jpg",
              timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
              type: MessageType.image), // Real image URL
        ],
      ),
      Chat(
        name: "Emily White",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar3.png", // Real profile picture URL
        lastMessage: "Check out this document",
        isUnread: false,
        unreadMessageCount: 0,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 2)),
        messages: [
          Message(
              sender: "Emily White",
              content: "Check out this document",
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              type: MessageType.text),
          Message(
              sender: "Emily White",
              content: "https://www.w3.org/WAI/WCAG21/quickref/files/WCAG21-quickref-2018.pdf",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.document), // Real document URL
          Message(
              sender: "Emily White",
              content: "https://www.w3schools.com/w3images/lights.jpg",
              timestamp: DateTime.now().subtract(const Duration(hours: 5)),
              type: MessageType.image), // Real image URL
        ],
      ),
    ];
  }
}
