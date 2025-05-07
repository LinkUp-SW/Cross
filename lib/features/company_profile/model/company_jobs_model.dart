// lib/features/company_profile/model/company_jobs_model.dart

class CompanyJobModel {
  final String id;
  final String jobTitle;
  final String location;
  final String jobType;
  final String postedTime;
  final String jobStatus;

  CompanyJobModel({
    required this.id,
    required this.jobTitle,
    required this.location,
    required this.jobType,
    required this.postedTime,
    required this.jobStatus,
  });

  factory CompanyJobModel.fromJson(Map<String, dynamic> json) {
    return CompanyJobModel(
      id: json['_id'] ?? '',
      jobTitle: json['job_title'] ?? '',
      location: json['location'] ?? '',
      jobType: json['job_type'] ?? '',
      postedTime: json['posted_time'] ?? '',
      jobStatus: json['job_status'] ?? '',
    );
  }
}