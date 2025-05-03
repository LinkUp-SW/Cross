class JobsCardModel {
  final String cardId;
  final String jobTitle;
  final String companyName;
  final String location;
  final String workType;
  final String companyPicture;
  final String postDate;
  final String? timeAgo;
  final String? experienceLevel;
  final int salary;
  const JobsCardModel({
    required this.cardId,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.workType,
    required this.companyPicture,
    required this.postDate,
    required this.salary,
    this.experienceLevel,
    this.timeAgo,
  });

  factory JobsCardModel.fromJson(Map<String, dynamic> json) {
    final organization = json['organization'] as Map<String, dynamic>;
    return JobsCardModel(
      cardId: json['_id'],
      jobTitle: json['job_title'],
      companyName: organization['name'],
      location: json['location'],
      workType: json['workplace_type'],
      companyPicture: organization['logo'],
      postDate: json['posted_time'],
      timeAgo: json['timeAgo'],
      salary: json['salary'],
      experienceLevel: json['experience_level'],
    );
  }

  get jobId => null;
}