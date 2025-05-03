class JobApplicationSubmitModel {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final int phoneNumber;
  final String countryCode;
  final String resume;
  final String? coverLetter;

  JobApplicationSubmitModel({
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.countryCode,
    required this.resume,
    this.coverLetter,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'resume': resume,
    };
    
    if (coverLetter != null && coverLetter!.isNotEmpty) {
      data['cover_letter'] = coverLetter;
    }
    
    return data;
  }
}