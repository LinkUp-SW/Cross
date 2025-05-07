class AppliedJobModel {
  final String id;
  final String jobTitle;
  final String location;
  final String workplaceType;
  final String experienceLevel;
  final int salary;
  final String postedTime;
  final String applicationStatus;
  final String applicationId;
  final OrganizationInfo organization;

  AppliedJobModel({
    required this.id,
    required this.jobTitle,
    required this.location,
    required this.workplaceType,
    required this.experienceLevel,
    required this.salary,
    required this.postedTime,
    required this.applicationStatus,
    required this.applicationId,
    required this.organization,
  });

  factory AppliedJobModel.fromJson(Map<String, dynamic> json) {
    return AppliedJobModel(
      id: json['_id'] ?? '',
      jobTitle: json['job_title'] ?? '',
      location: json['location'] ?? '',
      workplaceType: json['workplace_type'] ?? '',
      experienceLevel: json['experience_level'] ?? '',
      salary: json['salary'] ?? 0,
      postedTime: json['posted_time'] ?? '',
      applicationStatus: json['application_status'] ?? 'Pending',
      applicationId: json['application_id'] ?? '',
      organization: OrganizationInfo.fromJson(json['organization'] ?? {}),
    );
  }
}

class OrganizationInfo {
  final String id;
  final String name;
  final String logo;

  OrganizationInfo({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory OrganizationInfo.fromJson(Map<String, dynamic> json) {
    return OrganizationInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}