class  FogotPasswordModel {
  String? email;

  FogotPasswordModel({this.email});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    return data;
  }

  factory FogotPasswordModel.fromJson(Map<String, dynamic> json) {
    return FogotPasswordModel(
      email: json['email'],
    );
  }
}