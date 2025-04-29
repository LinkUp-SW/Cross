// lib/features/profile/model/education_model.dart
import 'dart:developer';

class EducationModel {
  final String? id;
  final Map<String, String>? schoolData; // <-- Changed to Map<String, String>?
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String? endDate;
  final String? grade;
  final String? activitesAndSocials; // Renamed to match JSON key
  final List<String>? skills; // Added
  final List<Map<String, dynamic>>? media; // Added
  final String? description;

  EducationModel({

    this.id,
    this.schoolData, // <-- Type updated
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
     Map<String, String>? fetchedSchoolData; // <-- Type updated
     String fetchedInstitution = json['institution'] as String? ?? '';

     if (json['school'] is Map) {
        // Convert dynamic map values to String, handling potential nulls
        final schoolMapDynamic = Map<String, dynamic>.from(json['school']);
        fetchedSchoolData = schoolMapDynamic.map((key, value) => MapEntry(key, value?.toString() ?? ''));
        // Filter out entries with empty string values if necessary, depends on requirements
        // fetchedSchoolData.removeWhere((key, value) => value.isEmpty);
        fetchedInstitution = fetchedSchoolData['name'] ?? fetchedInstitution;
     } else if (json['school'] is String) {
        // If only ID is returned, create the map accordingly
        fetchedSchoolData = {'_id': json['school'] as String};
        // Name and logo would be missing here
     }

    return EducationModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      schoolData: fetchedSchoolData, // <-- Store the map
      institution: fetchedInstitution,
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['field_of_study'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      grade: json['grade']?.toString(),
      activitesAndSocials: json['activites_and_socials'] as String?,
      description: json['description'] as String?,
      skills: (json['skills'] as List?)?.map((item) => item.toString()).toList(), // Added skills parsing
      media: (json['media'] as List?)?.map((item) { // Added media parsing
        if (item is Map<String, dynamic>) {
          // Ensure nested _id is stringified if needed, or handle types directly
          item['_id'] = item['_id']?.toString();
          return item;
        }
        return <String, dynamic>{}; // Return empty map for invalid entries
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
      if (grade != null && grade!.isNotEmpty) 'grade': grade, // Keep grade as is for sending
      if (activitesAndSocials != null && activitesAndSocials!.isNotEmpty) 'activites_and_socials': activitesAndSocials, // Adjusted key
      if (skills != null && skills!.isNotEmpty) 'skills': skills, // Added skills
      if (media != null && media!.isNotEmpty) 'media': media, // Added media
      if (schoolData != null &&
          schoolData!['_id'] != null &&
          schoolData!['name'] != null &&
          schoolData!['logo'] != null )
         'school': {
            '_id': schoolData!['_id']!, // Non-null assertion as checked
            'name': schoolData!['name']!, // Non-null assertion as checked
            'logo': schoolData!['logo']!, // Non-null assertion as checked
         },
    };
    return data;
  }
}