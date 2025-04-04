abstract class PastJobDetailsModel {
  String? location;

  PastJobDetailsModel({
    this.location,
  });
}

class Job extends PastJobDetailsModel {
  List<String>? jobTitle;
  List<String>? companyName;

  Job({
    this.jobTitle,
    this.companyName,
    super.location,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'companyName': companyName,
    };
  }
}

class Student extends PastJobDetailsModel {
  String? schoolName;
  String? startDate;

  Student({
    this.schoolName,
    this.startDate,
    super.location,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      schoolName: json['schoolName'],
      startDate: json['startDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolName': schoolName,
      'startDate': startDate,
    };
  }
}
