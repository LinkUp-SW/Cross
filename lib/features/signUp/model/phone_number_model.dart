class PhoneNumberModel {
  final String countryCode;
  final String number;

  PhoneNumberModel({
    required this.countryCode,
    required this.number,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'number': number,
    };
  }

  factory PhoneNumberModel.fromJson(Map<String, dynamic> json) {
    return PhoneNumberModel(
      countryCode: json['countryCode'] as String,
      number: json['number'] as String,
    );
  }
}