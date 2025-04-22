

class EducationModel {
  final String? id;
  final String institution; 
  final String degree;
  final String fieldOfStudy; 
  final String startDate; 
  final String? endDate; 
  final String? grade;
  final String? activities; 
  final String? description;

  EducationModel({
    this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.grade,
    this.activities,
    this.description,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'], 
      institution: json['institution'],
      degree: json['degree'],
      fieldOfStudy: json['field_of_study'], 
      startDate: json['start_date'],        
      endDate: json['end_date'],             
      grade: json['grade'],
      activities: json['activities'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'institution': institution,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate,        
      'description': description,
      if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
      if (grade != null && grade!.isNotEmpty) 'grade': grade,
      if (activities != null && activities!.isNotEmpty) 'activities': activities,
    };
    return data;
  }
}