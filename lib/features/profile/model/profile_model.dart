import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserProfile {
  final bool isMe;
  final String firstName;
  final String lastName;
  final String headline;
  final String? countryRegion;
  final String? city;
  final List<String> experience;
  final List<String> education;
  final String profilePhotoUrl;
  final String coverPhotoUrl;
  final int numberOfConnections;

  const UserProfile({
    required this.isMe,
    required this.firstName,
    required this.lastName,
    required this.headline,
    this.countryRegion,
    this.city,
    required this.experience,
    required this.education,
    required this.profilePhotoUrl,
    required this.coverPhotoUrl,
    required this.numberOfConnections,
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
      experience: List<String>.from(bio['experience'] as List? ?? []),
      education: List<String>.from(bio['education'] as List? ?? []),
      profilePhotoUrl: json['profile_photo'] as String? ?? '',
      coverPhotoUrl: json['cover_photo'] as String? ?? '',
      numberOfConnections: json['number_of_connections'] as int? ?? 0,
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
        'experience': experience,
        'education': education,
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
      experience: [],
      education: [],
      profilePhotoUrl: '',
      coverPhotoUrl: '',
      numberOfConnections: 0,
    );
  }
}