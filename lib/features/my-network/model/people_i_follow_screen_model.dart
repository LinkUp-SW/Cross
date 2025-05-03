class FollowingCardModel {
  final String cardId;
  final String name;
  final String title;
  final String profilePicture;

  const FollowingCardModel({
    required this.cardId,
    required this.name,
    required this.title,
    required this.profilePicture,
  });

  factory FollowingCardModel.fromJson(Map<String, dynamic> json) {
    return FollowingCardModel(
      cardId: json["user_id"],
      name: json['name'],
      title: json['headline'],
      profilePicture: json['profilePicture'],
    );
  }
}
