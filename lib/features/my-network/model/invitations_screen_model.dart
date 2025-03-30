class InvitationsCardModel {
  final String firstName;
  final String lastName;
  final String title;
  final String profilePicture;
  final int? mutualsCount;
  final String daysCount;

  const InvitationsCardModel({
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.profilePicture,
    this.mutualsCount,
    required this.daysCount,
  });

  factory InvitationsCardModel.fromJson(Map<String, dynamic> json) {
    return InvitationsCardModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      title: json['title'],
      profilePicture: json['profilePicture'],
      mutualsCount: json['mutualsCount'],
      daysCount: json['daysCount'],
    );
  }

  factory InvitationsCardModel.initial() {
    return const InvitationsCardModel(
      firstName: "Amanda",
      lastName: "Williams",
      title:
          "AI Engineer @ Open AI | Ex-Backend Engineer @ Amazon | Ex-Database Engineer @ Oracle",
      profilePicture: "assets/images/profile.png",
      mutualsCount: 64,
      daysCount: "2025-03-10T13:17:25.1392",
    );
  }
}
