import 'dart:developer';

class PeopleCardModel {
  final String cardId;
  final String name;
  final String? headline;
  final String? location;
  final String? profilePhoto;
  final String connectionDegree;
  final int mutualConnectionsCount;
  final String? firstMutualConnectionName;
  final String? firstMutualConnectionPicture;
  final bool isInSentConnectionInvitations;
  final bool isInReceivedConnectionInvitations;

  const PeopleCardModel({
    required this.cardId,
    required this.name,
    required this.headline,
    required this.location,
    required this.profilePhoto,
    required this.connectionDegree,
    required this.mutualConnectionsCount,
    required this.firstMutualConnectionName,
    required this.firstMutualConnectionPicture,
    required this.isInReceivedConnectionInvitations,
    required this.isInSentConnectionInvitations,
  });

  factory PeopleCardModel.fromJson(Map<String, dynamic> json) {
    try {
      return PeopleCardModel(
        cardId: json['user_id'],
        name: json['name'],
        headline: json['headline'],
        location: json['location'],
        profilePhoto: json['profile_photo'],
        connectionDegree: json['connection_degree'],
        mutualConnectionsCount: json['mutual_connections']['count'],
        firstMutualConnectionName: json['mutual_connections']['suggested_name'],
        firstMutualConnectionPicture: json['mutual_connections']
            ['suggested_profile_photo'],
        isInReceivedConnectionInvitations: json['is_in_sent_connections'],
        isInSentConnectionInvitations: json['is_in_received_connections'],
      );
    } catch (error) {
      log('Error in converting json response to people card model object: $error');
      rethrow;
    }
  }
}
