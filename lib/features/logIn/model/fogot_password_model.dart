class  FogotPasswordModel {
  String? email;

  FogotPasswordModel({this.email});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    return data;
  }

  factory FogotPasswordModel.fromJson(Map<String, dynamic> json) {
    return FogotPasswordModel(
      email: json['email'],
    );
  }
}