import 'dart:async';
import 'package:link_up/features/chat/model/chat_model.dart';
import 'package:link_up/features/chat/services/chat_service.dart';
import 'package:link_up/features/chat/model/message_model.dart';

class MockChatService implements ChatService {
  @override
  Future<List<Chat>> fetchChats() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    var chats = [
      Chat(
        userId:"1" ,
        name: "John Doe",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar2.png",
        lastMessage: "I'm good, thanks!",
        isUnread: true,
        unreadMessageCount: 2,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        messages: [
          Message(
              sender: "John Doe",
              content: "Hello, how are you?",
              timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
              type: MessageType.text,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "jumana",
              content: "I'm good, thanks!",
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              type: MessageType.text,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "John Doe",
              content: "https://www.w3schools.com/html/movie.mp4",
              timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              type: MessageType.video,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "jumana",
              content: "https://www.w3schools.com/w3images/fjords.jpg",
              timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
              type: MessageType.image,deliveryStatus: DeliveryStatus.sent), // Real video URL
          Message(
              sender: "John Doe",
              content: "https://css4.pub/2015/icelandic/dictionary.pdf",
              timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              type: MessageType.document,deliveryStatus: DeliveryStatus.sent),
        ],
        isTyping: false,
      ),
      Chat(
        userId: "2",   
        name: "Jane Smith",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar6.png",
        lastMessage: "Are we still on for tomorrow?",
        isUnread: false,
        unreadMessageCount: 0,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        messages: [
          Message(
              sender: "Jane Smith",
              content: "check this document",
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              type: MessageType.text,deliveryStatus: DeliveryStatus.read),
          Message(
               sender: "Jane Smith",
              content: "https://www.princexml.com/samples/catalog/PrinceCatalogue.pdf",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.document,deliveryStatus: DeliveryStatus.sent), // Real PDF document URL
        ],
        isTyping: false,
      ),
      Chat(
        userId: "3",
        name: "Sam Green",
        profilePictureUrl: "https://www.w3schools.com/w3images/avatar5.png",
        lastMessage: "Did you finish the report?",
        isUnread: false,
        unreadMessageCount: 1,
        lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        messages: [
          Message(
          sender: "Sam Green",
              content: "Take a look at this presentation",
              timestamp: DateTime.now().subtract(const Duration(days: 3)),
              type: MessageType.text,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "jumana",
              content: "Here's the link",
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              type: MessageType.text,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "Sam Green",
              content: "https://www.w3schools.com/html/movie.mp4",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.video,deliveryStatus: DeliveryStatus.sent), // Real document URL
          Message(
              sender: "jumana",
              content: "https://css4.pub/2015/usenix/example.pdf",
              timestamp: DateTime.now().subtract(const Duration(days : 1)),
              type: MessageType.document,deliveryStatus: DeliveryStatus.sent), // Real video URL
        ],
        isTyping: false,
      ),
      Chat(
        userId: "4",
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
              type: MessageType.text,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "jumana",
              content: "Check out this picture",
              timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
              type: MessageType.text,deliveryStatus: DeliveryStatus.sent),
          Message(
              sender: "Alex Blue",
              content: "https://www.w3schools.com/w3images/lights.jpg",
              timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
              type: MessageType.image,deliveryStatus: DeliveryStatus.sent), // Real image URL
        ],
        isTyping: false,

      ),
      Chat(
        userId: "5",
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
              type: MessageType.text,
              deliveryStatus: DeliveryStatus.sent),
              
              
          Message(
              sender: "Emily White",
              content: "https://www.princexml.com/samples/flyer/flyer.pdf",
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.document,deliveryStatus: DeliveryStatus.sent), // Real document URL
          Message(
              sender: "Emily White",
              content: "https://www.w3schools.com/w3images/lights.jpg",
              timestamp: DateTime.now().subtract(const Duration(hours: 5)),
              type: MessageType.image,deliveryStatus: DeliveryStatus.sent), // Real image URL
        ],
        isTyping: false,
      ),

      // Add more mock chat data here...
    ];

    return chats;
  }
}
