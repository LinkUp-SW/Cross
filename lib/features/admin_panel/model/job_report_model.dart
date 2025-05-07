// job_report_model.dart
class JobReportModel {
  final String jobId; // Corresponding to job_id
  final String type; // "Job"
  final String title; // Job title
  final String description; // Job description
  final Organization organization; // Organization details

  JobReportModel({
    required this.jobId,
    required this.type,
    required this.title,
    required this.description,
    required this.organization,
  });

  factory JobReportModel.fromJson(Map<String, dynamic> json) {
    return JobReportModel(
      jobId: json['_id'],
      type: json['type'] ?? '',
      title: json['title'] ?? 'No title',
      description: json['description'] ?? '',
      organization: Organization.fromJson(json['organization']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': jobId,
      'type': type,
      'title': title,
      'description': description,
      'organization': organization.toJson(),
    };
  }
}

class Organization {
  final String orgId;
  final String name;
  final String logo;

  Organization({
    required this.orgId,
    required this.name,
    required this.logo,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': orgId,
      'name': name,
      'logo': logo,
    };
  }
}
