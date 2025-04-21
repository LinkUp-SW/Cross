class JobsCardModel {
  final String jobTitle;
  final String companyName;
  final String country;
  final String city;
  final String workType;
  final String companyPicture;
  final String postDate;

  const JobsCardModel({
    required this.jobTitle,
    required this.companyName,
    required this.country,
    required this.city,
    required this.workType,
    required this.companyPicture,
    required this.postDate,
  });

  factory JobsCardModel.fromJson(Map<String, dynamic> json) {
    return JobsCardModel(
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
      country: json['country'],
      city: json['city'],
      workType: json['workType'],
      companyPicture: json['companyPicture'],
      postDate: json['postDate'],
    );
  }

  factory JobsCardModel.initial() {
    return JobsCardModel(
      jobTitle: 'AI Engineer',
      companyName: 'Open AI',
      country: 'Egypt',
      city: 'Cairo',
      workType: 'Hybrid',
      companyPicture: 'assets/images/default-company-picture.png',
      postDate: DateTime.now().toIso8601String(),
    );
  }
}