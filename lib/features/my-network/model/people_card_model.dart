class PeopleCardsModel {
  final String cardId;
  final String? profilePicture;
  final String? coverPicture;
  final String firstName;
  final String lastName;
  final String? title;
  final String whoCanSendMeInvitation;

  const PeopleCardsModel({
    required this.cardId,
    required this.profilePicture,
    required this.coverPicture,
    required this.firstName,
    required this.lastName,
    this.title,
    required this.whoCanSendMeInvitation,
  });

  factory PeopleCardsModel.fromJson(Map<String, dynamic> json) {
    return PeopleCardsModel(
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
