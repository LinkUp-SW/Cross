import 'package:flutter/foundation.dart' show immutable;
import 'dart:developer';

@immutable
class PositionModel {
  final String? id;
  final String title;
  final String employeeType;
  final String? organizationId;
  final String companyName;
  final bool isCurrent;
  final String startDate;
  final String? endDate;
  final String? description;
  final String? profileHeadline;
  final String? location;
  final String? locationType;

  const PositionModel({
    this.id,
    required this.title,
    required this.employeeType,
    required this.organizationId,
    required this.companyName,
    required this.isCurrent,
    required this.startDate,
    this.endDate,
    this.description,
    this.profileHeadline,
    this.location,
    this.locationType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title.trim(),
      'employee_type': employeeType,
      if (organizationId != null) 'organization': organizationId,
      'is_current': isCurrent,
      'start_date': startDate,
      if (!isCurrent && endDate != null) 'end_date': endDate,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (profileHeadline != null && profileHeadline!.isNotEmpty) 'profile_headline': profileHeadline,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (locationType != null && locationType!.isNotEmpty) 'location_type': locationType,
    };
    log('PositionModel toJson: $data');
    return data;
  }

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    String? orgId;
    String? orgName;
    if (json['organization'] is Map) {
        orgId = json['organization']['_id'] as String? ?? json['organization']['id'] as String?;
        orgName = json['organization']['name'] as String?;
    } else {
        orgId = json['organization'] as String?;
    }
    orgName ??= json['company_name'] as String? ?? json['organization_name'] as String?;


    return PositionModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      title: json['title'] as String? ?? '',
      organizationId: orgId,
      companyName: orgName ?? '',
      employeeType: json['employee_type'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool? ?? json['end_date'] == null,
      description: json['description'] as String?,
      profileHeadline: json['profile_headline'] as String?,
      location: json['location'] as String?,
      locationType: json['location_type'] as String?,
    );
  }
}