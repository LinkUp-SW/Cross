class ConnectionsCardModel {
  final String cardId;
  final String name;
  final String title;
  final String profilePicture;
  final String connectionDate;

  const ConnectionsCardModel({
    required this.cardId,
    required this.name,
    required this.title,
    required this.profilePicture,
    required this.connectionDate,
  });

  factory ConnectionsCardModel.fromJson(Map<String, dynamic> json) {
    return ConnectionsCardModel(
      cardId: json['user_id'],
      name: json['name'],
      title: json['headline'],
      profilePicture: json['profilePicture'],
      connectionDate: json['date'],
    );
  }
}
