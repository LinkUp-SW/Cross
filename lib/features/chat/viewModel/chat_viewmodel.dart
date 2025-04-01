import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/chat_model.dart';
import '../services/chat_service.dart';

// Define the ChatViewModel as a StateNotifier
class ChatViewModel extends StateNotifier<List<Chat>> {
  final ChatService _chatService;

  ChatViewModel(this._chatService) : super([]) {
    _fetchChats();
  }

  void _fetchChats() async {
    state = await _chatService.fetchChats();
  }

  void toggleReadUnreadStatus(int index) {
  state = [
    for (int i = 0; i < state.length; i++)
      if (i == index && state[i].isUnread) //  Only change if it's unread
        state[i].copyWith(isUnread: false)
      else
        state[i],
  ];
}
}

//Properly defined provider
final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, List<Chat>>((ref) {
  return ChatViewModel(ChatService());
});
