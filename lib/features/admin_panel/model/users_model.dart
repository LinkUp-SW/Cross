class UserModel {
  final String profileImageUrl;
  final String firstName;
  final String lastName;
  final String email;
  final String? password; // Optional: store or ignore
  final String id;
  final String type;

  UserModel({
    required this.profileImageUrl,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password, // Optional: store or ignore
    required this.id,
    required this.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      profileImageUrl: json['profile_picture'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'], // Optional: store or ignore
      id: json['id'] ?? "0",
      type: json['is_admin'] == true ? 'admin' : 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password, // Optional: store or ignore
    };
  }
}
