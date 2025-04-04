class VerficationModel {
  String? code;

  VerficationModel({
    this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }

  factory VerficationModel.fromJson(Map<String, dynamic> json) {
    return VerficationModel(
      code: json['code'] as String?,
    );
  }
}
