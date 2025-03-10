class GrowTabPeopleCardsModel {
  final String profilePicture;
  final String coverPicture;
  final String firstName;
  final String lastName;
  final String title;
  final String firstMutualConnectionProfilePicture;
  final String firstMutualConnectionFirstName;
  final String? secondMutualConnectionProfilePicture;
  final String? secondMutualConnectionFirstName;
  final int mutualConnectionsNumber;

  const GrowTabPeopleCardsModel({
    required this.profilePicture,
    required this.coverPicture,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.firstMutualConnectionProfilePicture,
    required this.firstMutualConnectionFirstName,
    this.secondMutualConnectionProfilePicture,
    this.secondMutualConnectionFirstName,
    required this.mutualConnectionsNumber,
  });

  factory GrowTabPeopleCardsModel.fromJson(Map<String, dynamic> json) {
    return GrowTabPeopleCardsModel(
      profilePicture: json['profilePicture'],
      coverPicture: json['coverPicture'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      title: json['title'],
      firstMutualConnectionProfilePicture:
          json['firstMutualConnectionProfilePicture'],
      firstMutualConnectionFirstName: json['firstMutualConnectionFirstName'],
      secondMutualConnectionProfilePicture:
          json['secondMutualConnectionProfilePicture'],
      secondMutualConnectionFirstName: json['secondMutualConnectionFirstName'],
      mutualConnectionsNumber: json['mutualConnectionsNumber'],
    );
  }

  factory GrowTabPeopleCardsModel.initial() {
    return const GrowTabPeopleCardsModel(
      profilePicture: "assets/images/profile.png",
      coverPicture: "assets/images/default-cover-picture.png",
      firstName: "Amanda",
      lastName: "Williams",
      title:
          "Teaching Assistant @ Cairo University Faculty of Biomedical and Healthcare Data Engineering",
      firstMutualConnectionProfilePicture: "assets/images/profile.png",
      firstMutualConnectionFirstName: "Sarah",
      secondMutualConnectionFirstName: "Jean",
      secondMutualConnectionProfilePicture: "assets/images/profile.png",
      mutualConnectionsNumber: 64,
    );
  }
}

class GrowTabNewsletterCardsModel {
  final String newsletterProfilePicture;
  final String newletterCoverPicture;
  final String newsletterName;
  final String newletterDescription;
  final String companyPicture;
  final String companyName;
  final int subscribersNumber;

  const GrowTabNewsletterCardsModel({
    required this.newsletterProfilePicture,
    required this.newletterCoverPicture,
    required this.newsletterName,
    required this.newletterDescription,
    required this.companyPicture,
    required this.companyName,
    required this.subscribersNumber,
  });

  factory GrowTabNewsletterCardsModel.fromJson(Map<String, dynamic> json) {
    return GrowTabNewsletterCardsModel(
      newsletterProfilePicture: json['newsletterProfilePicture'],
      newletterCoverPicture: json['newletterCoverPicture'],
      newsletterName: json['newsletterName'],
      newletterDescription: json['newletterDescription'],
      companyPicture: json['companyPicture'],
      companyName: json['companyName'],
      subscribersNumber: json['subscribersNumber'],
    );
  }
}
