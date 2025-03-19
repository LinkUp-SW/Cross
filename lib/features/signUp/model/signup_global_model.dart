class SignUpModel {
  String? fisrtName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;
  String? address;
  String? dateOfBirth;
  String? gender;

  SignUpModel({
    this.fisrtName,
    this.lastName,
    this.email,
    this.password,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      "firstName": fisrtName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "address": address,
      "dateOfBirth": dateOfBirth,
      "gender": gender,
    };
  }
}
