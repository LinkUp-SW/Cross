import 'package:flutter/foundation.dart' show immutable;
import 'dart:developer';

@immutable
class LicenseModel {
  final String? id;
  final String name;
  final String? issuingOrganizationId;
  final String issuingOrganizationName;
  final String? issuingOrganizationLogoUrl;
  final DateTime? issueDate;
  final DateTime? expirationDate;
  final bool doesNotExpire;
  final String? credentialId;
  final String? credentialUrl;
  final List<String>? skills;

  const LicenseModel({
    this.id,
    required this.name,
    this.issuingOrganizationId,
    required this.issuingOrganizationName,
    this.issuingOrganizationLogoUrl,
    this.issueDate,
    this.expirationDate,
    this.doesNotExpire = false,
    this.credentialId,
    this.credentialUrl,
    this.skills,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name.trim(),
      if (issuingOrganizationId != null) 'issuing_organization': issuingOrganizationId,
      'issue_date': issueDate?.toIso8601String().split('T').first,
      if (!doesNotExpire && expirationDate != null)
        'expiration_date': expirationDate!.toIso8601String().split('T').first,
      if (credentialId != null && credentialId!.isNotEmpty) 'credintial_id': credentialId!.trim(),
      if (credentialUrl != null && credentialUrl!.isNotEmpty) 'credintial_url': credentialUrl!.trim(),
      if (skills != null && skills!.isNotEmpty) 'skills': skills,
    };
    data.removeWhere((key, value) => value == null && key != 'expiration_date');
    log('LicenseModel toJson: $data');
    return data;
  }

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    String? orgName;
    String? orgLogo;
    String? orgId;

    if (json['issuing_organization'] is Map) {
      final organizationData = json['issuing_organization'] as Map<String, dynamic>;
      orgId = organizationData['_id'] as String? ?? organizationData['id'] as String?;
      orgName = organizationData['name'] as String?;
      orgLogo = organizationData['logo'] as String?;
      log("License fromJson: Found nested organization data. Name: $orgName, Logo: $orgLogo, ID: $orgId");
    } else if (json['issuing_organization'] is String) {
      orgId = json['issuing_organization'] as String;
      log("License fromJson: Found organization ID string: $orgId");
      orgName = json['issuing_organization_name'] as String?;
    }

    orgName ??= 'Unknown Organization';

    DateTime? parsedIssueDate = DateTime.tryParse(json['issue_date'] as String? ?? '');
    DateTime? parsedExpirationDate = DateTime.tryParse(json['expiration_date'] as String? ?? '');
    final bool doesExpireFlag = parsedExpirationDate != null;

    List<String>? parsedSkills = (json['skills'] as List?)?.map((item) => item.toString()).toList();

    return LicenseModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      issuingOrganizationId: orgId,
      issuingOrganizationName: orgName,
      issuingOrganizationLogoUrl: orgLogo,
      issueDate: parsedIssueDate,
      expirationDate: parsedExpirationDate,
      doesNotExpire: !doesExpireFlag,
      credentialId: json['credintial_id'] as String?,
      credentialUrl: json['credintial_url'] as String?,
      skills: parsedSkills,
    );
  }
}