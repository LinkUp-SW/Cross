class ConnectionsCardModel {
  final String cardId;
  final String firstName;
  final String lastName;
  final String title;
  final String profilePicture;
  final String connectionDate;

  const ConnectionsCardModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.profilePicture,
    required this.connectionDate,
  });

  factory ConnectionsCardModel.fromJson(Map<String, dynamic> json) {
    return ConnectionsCardModel(
      cardId: json['user_id'],
      firstName: json['name'].split(' ')[0],
      lastName: json['name'].split(' ')[1],
      title: json['headline'],
      profilePicture: json['profilePicture'],
      connectionDate: json['date'],
    );
  }
}
