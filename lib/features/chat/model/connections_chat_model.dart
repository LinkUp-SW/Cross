class ConnectionsChatModel {
  final String cardId;
  final String firstName;
  final String lastName;
  final String title;
  final String profilePicture;
  final String connectionDate;
  final bool isExistingChat;

  const ConnectionsChatModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.profilePicture,
    required this.connectionDate,
    this.isExistingChat = false,
  });

  factory ConnectionsChatModel.fromJson(Map<String, dynamic> json) {
    return ConnectionsChatModel(
      cardId: json['user_id'],
      firstName: json['name'].split(' ')[0],
      lastName: json['name'].split(' ').last,
      title: json['headline'],
      profilePicture: json['profilePicture'],
      connectionDate: json['date'],
    );
  }
}
