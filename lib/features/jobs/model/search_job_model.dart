class SearchJobModel {
  final String jobId;
  final String jobTitle;
  final String jobLocation;
  final String workplaceType;
  final String experienceLevel;
  final int salary;
  final String timeAgo;
  final bool isSaved;
  final String companyName;
  final String companyLogo;
  

  const SearchJobModel({
    required this.jobId,
    required this.jobTitle,
    required this.jobLocation,
    required this.workplaceType,
    required this.experienceLevel,
    required this.salary,
    required this.timeAgo,
    required this.isSaved,
    required this.companyName,
    required this.companyLogo,
  });

  factory SearchJobModel.fromJson(Map<String, dynamic> json) {
    final organization = json['organization'] as Map<String, dynamic>;
    return SearchJobModel(
      jobId: json['_id'],
      jobTitle: json['job_title'],
      jobLocation: json['location'],
      workplaceType: json['workplace_type'],
      experienceLevel: json['experience_level'],
      salary: json['salary'] ,
      timeAgo: json['timeAgo'],
      isSaved: json['is_saved'] ,
      companyName: organization['name'],
      companyLogo: organization['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': jobId,
      'job_title': jobTitle,
      'location': jobLocation,
      'workplace_type': workplaceType,
      'experience_level': experienceLevel,
      'salary': salary,
      'timeAgo': timeAgo,
      'is_saved': isSaved,
      'organization': {
        'name': companyName,
        'logo': companyLogo,
      },
    };
  }
}
