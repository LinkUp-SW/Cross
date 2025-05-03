class SavedJobsModel {
  final String jobId;
  final String jobTitle;
  final String location;
  final String workplaceType;
  final String experienceLevel;
  final int salary;
  final String organizationName;
  final String logo;
  final String timeAgo;

  SavedJobsModel({
    required this.jobId,
    required this.jobTitle,
    required this.location,
    required this.workplaceType,
    required this.experienceLevel,
    required this.salary,
    required this.organizationName,
    required this.logo,
    required this.timeAgo,
  });

  factory SavedJobsModel.fromJson(Map<String, dynamic> json) {
    final organization = json['organization'] as Map<String, dynamic>;
    return SavedJobsModel(
      jobId: json['_id'],
      jobTitle: json['job_title'],
      location: json['location'],
      workplaceType: json['workplace_type'],
      experienceLevel: json['experience_level'],
      salary: json['salary'],
      organizationName: organization['name'],
      logo: organization['logo'],
      timeAgo: json['timeAgo'],
    );
  }

}