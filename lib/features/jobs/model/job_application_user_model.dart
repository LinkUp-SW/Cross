class JobApplicationUserModel {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final int phoneNumber;
  final String countryCode;
  final String resume;

  JobApplicationUserModel({
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.countryCode,
    required this.resume,
  });

  factory JobApplicationUserModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationUserModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailAddress: json['email_address'] ?? '',
      phoneNumber: json['phone_number'] ?? 0,
      countryCode: json['country_code'] ?? '',
      resume: json['resume'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'resume': resume,
    };
  }
}