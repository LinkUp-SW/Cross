import 'dart:developer';

class EducationModel {
  final String? id;
  final Map<String, String>? schoolData;
  final String institution;
  final String? logoUrl;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String? endDate;
  final String? grade;
  final String? activitesAndSocials;
  final List<String>? skills;
  final List<Map<String, dynamic>>? media;
  final String? description;

  EducationModel({
    this.id,
    this.schoolData,
    this.logoUrl,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.grade,
    this.activitesAndSocials,
    this.skills,
    this.media,
    this.description,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    Map<String, String>? fetchedSchoolData;
    String fetchedInstitution = json['institution'] as String? ?? '';
    String? fetchedLogoUrl;
    if (json['school'] is Map) {
      final schoolMapDynamic = Map<String, dynamic>.from(json['school']);
      fetchedSchoolData = schoolMapDynamic.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      fetchedInstitution = fetchedSchoolData['name'] ?? fetchedInstitution;
      fetchedLogoUrl = fetchedSchoolData['logo'];
    } else if (json['school'] is String) {
      fetchedSchoolData = {'_id': json['school'] as String};
    }

    return EducationModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      schoolData: fetchedSchoolData,
      institution: fetchedInstitution,
      logoUrl: fetchedLogoUrl,
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['field_of_study'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      grade: json['grade']?.toString(),
      activitesAndSocials: json['activites_and_socials'] as String?,
      description: json['description'] as String?,
      skills: (json['skills'] as List?)?.map((item) => item.toString()).toList(),
      media: (json['media'] as List?)?.map((item) {
        if (item is Map<String, dynamic>) {
          item['_id'] = item['_id']?.toString();
          return item;
        }
        return <String, dynamic>{};
      }).whereType<Map<String, dynamic>>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
      if (grade != null && grade!.isNotEmpty) 'grade': grade,
      if (activitesAndSocials != null && activitesAndSocials!.isNotEmpty) 'activites_and_socials': activitesAndSocials,
      if (skills != null && skills!.isNotEmpty) 'skills': skills,
      if (media != null && media!.isNotEmpty) 'media': media,
      if (schoolData != null &&
          schoolData!['_id'] != null &&
          schoolData!['name'] != null &&
          schoolData!['logo'] != null)
        'school': {
          '_id': schoolData!['_id']!,
          'name': schoolData!['name']!,
          'logo': schoolData!['logo']!,
        },
    };
    return data;
  }
}