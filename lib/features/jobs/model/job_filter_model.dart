/*class JobFilterModel {
  final String? location;
  final List<String>? experienceLevel;
  final int? minSalary;
  final int? maxSalary;

  const JobFilterModel({
    this.location,
    this.experienceLevel,
    this.minSalary,
    this.maxSalary,
  });

  factory JobFilterModel.fromJson(Map<String, dynamic> json) {
    return JobFilterModel(
      location: json['location'],
      experienceLevel: json['experienceLevel'] != null 
          ? List<String>.from(json['experienceLevel']) 
          : null,
      minSalary: json['minSalary'],
      maxSalary: json['maxSalary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (location != null) 'location': location,
      if (experienceLevel != null) 'experienceLevel': experienceLevel,
      if (minSalary != null) 'minSalary': minSalary,
      if (maxSalary != null) 'maxSalary': maxSalary,
    };
  }
}*/