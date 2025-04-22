class GrowTabPeopleCardsModel {
  final String cardId;
  final String? profilePicture;
  final String? coverPicture;
  final String firstName;
  final String lastName;
  final String? title;
  final String whoCanSendMeInvitation;

  const GrowTabPeopleCardsModel({
    required this.cardId,
    required this.profilePicture,
    required this.coverPicture,
    required this.firstName,
    required this.lastName,
    this.title,
    required this.whoCanSendMeInvitation,
  });

  factory GrowTabPeopleCardsModel.fromJson(Map<String, dynamic> json) {
    return GrowTabPeopleCardsModel(
      cardId: json['user_id'],
      profilePicture: json['profile_photo'],
      coverPicture: json['cover_photo'],
      firstName: json['bio']['first_name'],
      lastName: json['bio']['last_name'],
      title: json['bio']['headline'],
      whoCanSendMeInvitation: json['privacy_settings']
          ['flag_who_can_send_you_invitations'],
    );
  }
}
