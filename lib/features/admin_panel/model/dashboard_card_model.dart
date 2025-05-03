class JobPostingModel {
  final int pendingCount;
  final int approvedTodayCount;
  final int rejectedTodayCount;

  JobPostingModel({
    required this.pendingCount,
    required this.approvedTodayCount,
    required this.rejectedTodayCount,
  });

  // Example of a factory constructor for creating an instance from a JSON object
  factory JobPostingModel.fromJson(Map<String, dynamic> json) {
    return JobPostingModel(
      pendingCount: json['pendingCount'] ?? 0,
      approvedTodayCount: json['approvedTodayCount'] ?? 0,
      rejectedTodayCount: json['rejectedTodayCount'] ?? 0,
    );
  }

  // Method to convert the model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'pendingCount': pendingCount,
      'approvedTodayCount': approvedTodayCount,
      'rejectedTodayCount': rejectedTodayCount,
    };
  }
}
