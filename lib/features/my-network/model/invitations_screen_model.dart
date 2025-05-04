class InvitationsCardModel {
  final String cardId;
  final String name;
  final String title;
  final String profilePicture;
  final int? mutualsCount;
  final String daysCount;

  const InvitationsCardModel({
    required this.cardId,
    required this.name,
    required this.title,
    required this.profilePicture,
    this.mutualsCount,
    required this.daysCount,
  });

  factory InvitationsCardModel.fromJson(Map<String, dynamic> json) {
    return InvitationsCardModel(
      cardId: json["user_id"],
      name: json['name'],
      title: json['headline'],
      profilePicture: json['profilePicture'],
      mutualsCount: json['numberOfMutualConnections'],
      daysCount: json['date'],
    );
  }
}
