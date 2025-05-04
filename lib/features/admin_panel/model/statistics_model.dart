class GraphData {
  final String title;
  final List<String> xValues;
  final List<double> yValues;
  final String type; // Bar or Line

  GraphData({
    required this.title,
    required this.xValues,
    required this.yValues,
    this.type = 'line',
  });
}

class AnalyticsResponse {
  final String message;
  final String period;
  final String interval;
  final AnalyticsData data;

  AnalyticsResponse({
    required this.message,
    required this.period,
    required this.interval,
    required this.data,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      message: json['message'],
      period: json['period'],
      interval: json['interval'],
      data: AnalyticsData.fromJson(json['data']),
    );
  }
}

class AnalyticsData {
  final List<DataPoint> userGrowth;
  final ContentCreation contentCreation;
  final EngagementMetrics engagementMetrics;
  final JobMetrics jobMetrics;

  AnalyticsData({
    required this.userGrowth,
    required this.contentCreation,
    required this.engagementMetrics,
    required this.jobMetrics,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      userGrowth: (json['userGrowth'] as List)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      contentCreation: ContentCreation.fromJson(json['contentCreation']),
      engagementMetrics: EngagementMetrics.fromJson(json['engagementMetrics']),
      jobMetrics: JobMetrics.fromJson(json['jobMetrics']),
    );
  }
}

class DataPoint {
  final String date;
  final int count;

  DataPoint({
    required this.date,
    required this.count,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      date: json['date'],
      count: json['count'],
    );
  }
}

class ContentCreation {
  final List<DataPoint> posts;

  ContentCreation({required this.posts});

  factory ContentCreation.fromJson(Map<String, dynamic> json) {
    return ContentCreation(
      posts: (json['posts'] as List).map((item) => DataPoint.fromJson(item)).toList(),
    );
  }
}

class EngagementMetrics {
  final List<DataPoint> reactions;
  final List<DataPoint> connections;
  final List<DataPoint> comments;

  EngagementMetrics({
    required this.reactions,
    required this.connections,
    required this.comments,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) {
    return EngagementMetrics(
      reactions: (json['reactions'] as List).map((item) => DataPoint.fromJson(item)).toList(),
      connections: (json['connections'] as List).map((item) => DataPoint.fromJson(item)).toList(),
      comments: (json['comments'] as List).map((item) => DataPoint.fromJson(item)).toList(),
    );
  }
}

class JobMetrics {
  final List<DataPoint> jobsPosted;

  JobMetrics({required this.jobsPosted});

  factory JobMetrics.fromJson(Map<String, dynamic> json) {
    return JobMetrics(
      jobsPosted: (json['jobsPosted'] as List).map((item) => DataPoint.fromJson(item)).toList(),
    );
  }
}