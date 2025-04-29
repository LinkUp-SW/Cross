class JobDetailsModel {
  final String jobId;
  final String jobTitle;
  final String location;
  final String workplaceType;
  final String experienceLevel;
  final String description;
  final List<String> qualifications;
  final List<String> responsibilities;
  final List<String> benefits;
  final String postedTime;
  final String timeAgo;
  final String organizationName;
  final String logo;
  final bool isSaved;

  JobDetailsModel({
    required this.jobId,
    required this.jobTitle,
    required this.location,
    required this.workplaceType,
    required this.experienceLevel,
    required this.description,
    required this.qualifications,
    required this.responsibilities,
    required this.benefits,
    required this.postedTime,
    required this.timeAgo,
    required this.organizationName,
    required this.logo,
    required this.isSaved,
  });

  factory JobDetailsModel.fromJson(Map<String, dynamic> json) {
    final organization = json['organization'] as Map<String, dynamic>;
    return JobDetailsModel(
      jobId: json['_id'] ?? '',
      jobTitle: json['job_title'] ?? '',
      location: json['location'] ?? '',
      workplaceType: json['workplace_type'] ?? '',
      experienceLevel: json['experience_level'] ?? '',
      description: json['description'] ?? '',
      qualifications: List<String>.from(json['qualifications'] ?? []),
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      postedTime: json['posted_time'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      organizationName: organization['name'] ?? '',
      logo: organization['logo'] ?? '',
      isSaved: json['is_saved'],
    );
  }
}


  