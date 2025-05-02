class ReportModel {
  final String id;
  final String type; // "Post", "Comment", "Job Listing"
  final String description;
  final String status; // "Pending", "Resolved"

  ReportModel({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
  });

  ReportModel copyWith({String? status}) {
    return ReportModel(
      id: id,
      type: type,
      description: description,
      status: status ?? this.status,
    );
  }
}

class NewAdminData {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? password;

  NewAdminData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
  });

  NewAdminData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['password'] = password;
    return data;
  }
}
