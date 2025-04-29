class SaveJobModel {
  final String message;


  SaveJobModel({
    required this.message,
  });

  factory SaveJobModel.fromJson(Map<String, dynamic> json) {
    return SaveJobModel(
      message: json['message'],
    );
  }
}

