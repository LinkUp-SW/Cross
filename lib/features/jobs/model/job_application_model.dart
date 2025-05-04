class JobApplicationModel {
  final String id;
  final String jobId;
  final UserInfo userId;
  final String firstName;
  final String lastName;
  final String emailAddress;
  final int phoneNumber;
  final String countryCode;
  final String resume;
  final String applicationStatus;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.countryCode,
    required this.resume,
    required this.applicationStatus,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['_id'] ?? '',
      jobId: json['job_id'] ?? '',
      userId: UserInfo.fromJson(json['user_id'] ?? {}),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailAddress: json['email_address'] ?? '',
      phoneNumber: json['phone_number'] ?? 0,
      countryCode: json['country_code'] ?? '',
      resume: json['resume'] ?? '',
      applicationStatus: json['application_status'] ?? 'Pending',
    );
  }
}

class UserInfo {
  final String id;
  final Map<String, dynamic> bio;
  final String profilePhoto;
  final String location;
  final String resume;

  UserInfo({
    required this.id,
    required this.bio,
    required this.profilePhoto,
    required this.location,
    required this.resume,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      bio: json['bio'] ?? {},
      profilePhoto: json['profile_photo'] ?? '',
      location: json['location'] ?? '',
      resume: json['resume'] ?? '',
    );
  }
}
