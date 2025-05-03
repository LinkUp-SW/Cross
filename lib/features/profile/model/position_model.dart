import 'package:flutter/foundation.dart' show immutable;
import 'dart:developer';

@immutable
class PositionModel {
  final String? id;
  final String title;
  final String employeeType;
  final String? organizationId;
  final String companyName;
  final String? companyLogoUrl; 
  final bool isCurrent;
  final String startDate;
  final String? endDate;
  final String? description;
  final String? profileHeadline;
  final String? location;
  final String? locationType;
  final List<String>? skills;
  final List<Map<String, dynamic>>? media;

  const PositionModel({
    this.id,
    required this.title,
    required this.employeeType,
    required this.organizationId,
    required this.companyName,
    this.companyLogoUrl, 
    required this.isCurrent,
    required this.startDate,
    this.endDate,
    this.description,
    this.profileHeadline,
    this.location,
    this.locationType,
    this.skills,
    this.media,
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
      if (skills != null && skills!.isNotEmpty) 'skills': skills,
      if (media != null && media!.isNotEmpty) 'media': media,
    };
    return data;
  }

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    String? orgName;
    String? orgLogo; 
    String? orgId;

    Map<String, dynamic>? organizationData;
    if (json['organization'] is Map) {
        organizationData = json['organization'] as Map<String, dynamic>?;
        orgId = organizationData?['_id'] as String? ?? organizationData?['id'] as String?;
        orgName = organizationData?['name'] as String?;
        orgLogo = organizationData?['logo'] as String?;
    } else if (json['organization'] is String) {
        orgId = json['organization'] as String?;
    }

    orgName ??= json['company_name'] as String? ?? json['organization_name'] as String?;

    List<String>? parsedSkills = (json['skills'] as List?)?.map((item) => item.toString()).toList();

    List<Map<String, dynamic>>? parsedMedia = (json['media'] as List?)?.map((item) {
      if (item is Map<String, dynamic>) {
        item['_id'] = item['_id']?.toString();
        return item;
      }
      return <String, dynamic>{};
    }).whereType<Map<String, dynamic>>().toList();

    return PositionModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      title: json['title'] as String? ?? '',
      organizationId: orgId,
      companyName: orgName ?? '', 
      companyLogoUrl: orgLogo, 
      employeeType: json['employee_type'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool? ?? json['end_date'] == null,
      description: json['description'] as String?,
      profileHeadline: json['profile_headline'] as String?,
      location: json['location'] as String?,
      locationType: json['location_type'] as String?,
      skills: parsedSkills,
      media: parsedMedia,
    );
  }
}