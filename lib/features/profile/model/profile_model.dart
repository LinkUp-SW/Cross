import 'package:flutter/foundation.dart' show immutable;
import 'package:link_up/features/profile/model/education_model.dart';

@immutable
class UserProfile {
  final bool isMe;
  final String firstName;
  final String lastName;
  final String headline;
  final String? countryRegion;
  final String? city;
  final String? website;
  final String profilePhotoUrl;
  final String coverPhotoUrl;
  final int numberOfConnections;
  final String? nameOfOneMutualConnection;
  final bool? followPrimary; 
  final bool? isSubscribed; 
  final bool? viewUserSubscribed;
  final bool? isConnectByEmail;
  final bool? isInConnections; 
  final bool? isInReceivedConnections; 
  final bool? isInSentConnections;
  final bool? isAlreadyFollowing; 
  final bool? allowMessaging;
  



  const UserProfile({
    required this.isMe,
    required this.firstName,
    required this.lastName,
    required this.headline,
    this.countryRegion,
    this.city,
    this.website, 
    required this.profilePhotoUrl,
    required this.coverPhotoUrl,
    required this.numberOfConnections,
    this.isInConnections,
    this.isInReceivedConnections,
    this.isInSentConnections, 
    this.isAlreadyFollowing,
    this.allowMessaging,
    this.nameOfOneMutualConnection,
    this.followPrimary,
    this.isSubscribed,
    this.viewUserSubscribed,
    this.isConnectByEmail,



    

  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final bio = json['bio'] as Map<String, dynamic>? ?? {};
    final contactInfo = bio['contact_info'] as Map<String, dynamic>? ?? {};
    final location = bio['location'] as Map<String, dynamic>? ?? {};
 
  
    return UserProfile(
      isMe: json['is_me'] as bool? ?? false,
      firstName: bio['first_name'] as String? ?? 'N/A',
      lastName: bio['last_name'] as String? ?? 'N/A',
      headline: bio['headline'] as String? ?? 'No Headline',
      countryRegion: location['country_region'] as String?,
      city: location['city'] as String?,
      profilePhotoUrl: json['profile_photo'] as String? ?? '',
      website: contactInfo['website'] as String? ?? bio['website'] as String?,     
      coverPhotoUrl: json['cover_photo'] as String? ?? '',
      numberOfConnections: json['number_of_connections'] as int? ?? 0,
       isInConnections: json['isInConnections'] as bool? ?? false,
      isInReceivedConnections: json['isInReceivedConnections'] as bool? ?? false,
      isInSentConnections: json['isInSentConnections'] as bool? ?? false,
      isAlreadyFollowing: json['isAlreadyFollowing'] as bool? ?? false,
      allowMessaging: json['allowMessaging'] as bool? ?? false,
      nameOfOneMutualConnection: json['name_of_one_mutual_connection'] as String?,
      followPrimary: json['follow_primary'] as bool? ?? false,
      isSubscribed: json['isSubscribed'] as bool? ?? false, 
      viewUserSubscribed: json['view_user_is_subscribed'] as bool? ?? false,
      isConnectByEmail: json['isConnectedByEmail'] as bool? ?? false,

    );
  }

 Map<String, dynamic> toJson() {
    return {
      'is_me': isMe,
      'bio': {
        'first_name': firstName,
        'last_name': lastName,
        'headline': headline,
        'location': {
          'country_region': countryRegion,
          'city': city,
        },
         'website': website,
      },
      'profile_photo': profilePhotoUrl,
      'cover_photo': coverPhotoUrl,
      'number_of_connections': numberOfConnections,
    };
  }


  factory UserProfile.initial() {
    return const UserProfile(
      isMe: false,
      firstName: '',
      lastName: '',
      headline: '',
      countryRegion: null,
      city: null,
      website: null,
      profilePhotoUrl: '',
      coverPhotoUrl: '',
      numberOfConnections: 0,
      isInConnections: false,
      isInReceivedConnections: false,
      isInSentConnections: false,
      isAlreadyFollowing: false,
      allowMessaging: false,
      nameOfOneMutualConnection: null,
      followPrimary: false,
      isSubscribed: false,
      viewUserSubscribed: false,
      isConnectByEmail: false,

    );
  }
  UserProfile copyWith({
      bool? isMe,
      String? firstName,
      String? lastName,
      String? headline,
      String? countryRegion,
      String? city,
      String? website,
      String? profilePhotoUrl,
      String? coverPhotoUrl,
      int? numberOfConnections,

      bool? isInConnections,
      bool? isInReceivedConnections,
      bool? isInSentConnections,  
      bool? isAlreadyFollowing,
      bool? allowMessaging,

      String? nameOfOneMutualConnection,
      bool? followPrimary,
      bool? isSubscribed,
      bool? viewUserSubscribed,
      bool? isConnectByEmail,

   }) {
      return UserProfile(
 
        isMe: isMe ?? this.isMe,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        headline: headline ?? this.headline,
        countryRegion: countryRegion == const Object() ? this.countryRegion : countryRegion as String?, 
        city: city == const Object() ? this.city : city as String?,
        website: website == const Object() ? this.website : website as String?,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
        numberOfConnections: numberOfConnections ?? this.numberOfConnections,
        isInConnections: isInConnections ?? this.isInConnections,
        isInReceivedConnections: isInReceivedConnections ?? this.isInReceivedConnections,
        isInSentConnections: isInSentConnections ?? this.isInSentConnections,
        isAlreadyFollowing: isAlreadyFollowing ?? this.isAlreadyFollowing,
        allowMessaging: allowMessaging ?? this.allowMessaging,
        nameOfOneMutualConnection: nameOfOneMutualConnection ?? this.nameOfOneMutualConnection, 
        followPrimary: followPrimary ?? this.followPrimary,
        isSubscribed: isSubscribed ?? this.isSubscribed,
        viewUserSubscribed: viewUserSubscribed ?? this.viewUserSubscribed,
        isConnectByEmail: isConnectByEmail ?? this.isConnectByEmail,


      );
   }
    @override
   bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          isMe == other.isMe &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          headline == other.headline &&
          countryRegion == other.countryRegion &&
          city == other.city &&
          website == other.website &&
          profilePhotoUrl == other.profilePhotoUrl &&
          coverPhotoUrl == other.coverPhotoUrl &&
          numberOfConnections == other.numberOfConnections &&
          isInReceivedConnections == other.isInReceivedConnections &&
          isInSentConnections == other.isInSentConnections &&
          isAlreadyFollowing == other.isAlreadyFollowing &&
          allowMessaging == other.allowMessaging &&
          isInConnections == other.isInConnections &&
          nameOfOneMutualConnection == other.nameOfOneMutualConnection &&
          followPrimary == other.followPrimary &&
          isSubscribed == other.isSubscribed &&
          viewUserSubscribed == other.viewUserSubscribed &&
          isConnectByEmail == other.isConnectByEmail;
          

   @override
   int get hashCode =>
       isMe.hashCode ^
       firstName.hashCode ^
        lastName.hashCode ^
        headline.hashCode ^
        countryRegion.hashCode ^
        city.hashCode ^
        website.hashCode ^
        profilePhotoUrl.hashCode ^
        coverPhotoUrl.hashCode ^
        numberOfConnections.hashCode ^
        isInReceivedConnections.hashCode ^
        isInSentConnections.hashCode ^
        isAlreadyFollowing.hashCode ^
        allowMessaging.hashCode ^
        isInConnections.hashCode ^
        nameOfOneMutualConnection.hashCode ^
        followPrimary.hashCode ^
        isSubscribed.hashCode ^
        viewUserSubscribed.hashCode ^
        isConnectByEmail.hashCode;
        

        
}
