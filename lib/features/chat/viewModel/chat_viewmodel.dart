import '../model/chat_model.dart';
import '../services/chat_service.dart';

class ChatViewModel {
  final ChatService _chatService = ChatService();

  Future<List<Chat>> getChats() async {
    return await _chatService.fetchChats();
  }
}