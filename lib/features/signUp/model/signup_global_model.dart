class SignUpModel {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;
  String? countryCode;
  String? country;
  String? city;
  String? jobTitle;
  String? recentCompany;
  String? school;
  String? startDate;
  String? location;
  String? address;
  String? dateOfBirth;
  String? gender;
  bool? isStudent;

  SignUpModel({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.phoneNumber = '',
    this.countryCode = '',
    this.country = '',
    this.city = '',
    this.jobTitle = '',
    this.recentCompany = '',
    this.school = '',
    this.startDate = '',
    this.location = '',
    this.address = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.isStudent = false,
  });

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "countryCode": countryCode,
      "country": country,
      "city": city,
      "jobTitle": jobTitle,
      "recentCompany": recentCompany,
      "school": school,
      "startDate": startDate,
      "location": location,
      "address": address,
      "isStudent": isStudent
    };
  }

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password'],
        phoneNumber: json['phoneNumber'],
        countryCode: json['countryCode'],
        country: json['country'],
        city: json['city'],
        jobTitle: json['jobTitle'],
        recentCompany: json['recentCompany'],
        school: json['school'],
        startDate: json['startDate'],
        location: json['location'],
        address: json['address'],
        isStudent: json['isStudent']);
  }
}
