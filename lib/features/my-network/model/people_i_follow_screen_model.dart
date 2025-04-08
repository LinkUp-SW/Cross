class FollowingCardModel {
  final String cardId;
  final String firstName;
  final String lastName;
  final String title;
  final String profilePicture;

  const FollowingCardModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.profilePicture,
  });

  factory FollowingCardModel.fromJson(Map<String, dynamic> json) {
    return FollowingCardModel(
      cardId: json["user_id"],
      firstName: json['name'].split(" ")[0],
      lastName: json['name'].split(" ").last,
      title: json['headline'],
      profilePicture: json['profilePicture'],
    );
  }
}
