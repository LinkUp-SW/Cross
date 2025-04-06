class InvitationsCardModel {
  final String cardId;
  final String firstName;
  final String lastName;
  final String title;
  final String profilePicture;
  final int? mutualsCount;
  final String daysCount;

  const InvitationsCardModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.profilePicture,
    this.mutualsCount,
    required this.daysCount,
  });

  factory InvitationsCardModel.fromJson(Map<String, dynamic> json) {
    return InvitationsCardModel(
      cardId: json["user_id"],
      firstName: json['name'].split(" ")[0],
      lastName: json['name'].split(" ").last,
      title: json['headline'],
      profilePicture: json['profilePicture'],
      mutualsCount: json['numberOfMutualConnections'],
      daysCount: json['date'],
    );
  }
}
