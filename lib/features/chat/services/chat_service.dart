import 'package:link_up/features/chat/model/chat_model.dart';

abstract class ChatService {
  Future<List<Chat>> fetchChats();

}
