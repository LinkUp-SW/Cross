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
      secondMutualConnectionProfilePicture:
          "assets/images/default-profile-picture.jpg",
      mutualConnectionsNumber: 64,
    );
  }
}

class GrowTabNewsletterCardsModel {
  final String newsletterProfilePicture;
  final String newsletterCoverPicture;
  final String newsletterName;
  final String newsletterDescription;
  final String companyPicture;
  final String companyName;
  final int subscribersNumber;

  const GrowTabNewsletterCardsModel({
    required this.newsletterProfilePicture,
    required this.newsletterCoverPicture,
    required this.newsletterName,
    required this.newsletterDescription,
    required this.companyPicture,
    required this.companyName,
    required this.subscribersNumber,
  });

  factory GrowTabNewsletterCardsModel.fromJson(Map<String, dynamic> json) {
    return GrowTabNewsletterCardsModel(
      newsletterProfilePicture: json['newsletterProfilePicture'],
      newsletterCoverPicture: json['newsletterCoverPicture'],
      newsletterName: json['newsletterName'],
      newsletterDescription: json['newsletterDescription'],
      companyPicture: json['companyPicture'],
      companyName: json['companyName'],
      subscribersNumber: json['subscribersNumber'],
    );
  }

  factory GrowTabNewsletterCardsModel.initial() {
    return const GrowTabNewsletterCardsModel(
      newsletterProfilePicture: "assets/images/default-company-picture.png",
      newsletterCoverPicture: "assets/images/default-cover-picture.png",
      newsletterName: "LinkUp Jobs Market",
      newsletterDescription:
          "Welcome to LinkUp Job Market Data, your weekly dose of jobs market news",
      companyPicture: "assets/images/Logo_mini.png",
      companyName: "LinkUp",
      subscribersNumber: 23253680,
    );
  }
}

class CatchTabCardsModel {
  final String firstName;
  final String lastName;
  final String profilePicture;
  final String? title;
  final String message;
  final int? likesCount;
  final int? commentsCount;
  final String buttonMessage;

  const CatchTabCardsModel({
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    this.title,
    required this.message,
    this.likesCount,
    this.commentsCount,
    required this.buttonMessage,
  });

  factory CatchTabCardsModel.fromJson(Map<String, dynamic> json) {
    return CatchTabCardsModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
      message: json['message'],
      likesCount: json['likesCount'],
      commentsCount: json['commentsCount'],
      buttonMessage: json['lastName'],
    );
  }

  factory CatchTabCardsModel.initial() {
    return const CatchTabCardsModel(
      firstName: "Amanda",
      lastName: "Williams",
      profilePicture: "assets/images/profile.png",
      title: "Ai Engineer at Amazon",
      message: "Started a new position as Ai Engineer at Amazon",
      buttonMessage: "Congrats",
      likesCount: 86,
      commentsCount: 124,
    );
  }
}

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
      daysCount: "2025-03-22T13:17:25.1392",
    );
  }
}
