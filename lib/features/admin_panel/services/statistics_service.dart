import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/admin_panel/model/statistics_model.dart';

class StatisticsService extends BaseService {
  Future<List<GraphData>> fetchStatistics(String range) async {
    try {
      final response = await get(
        'api/v1/admin/analytics',
        queryParameters: {
          'period': range,
        },
      );

      if (response.statusCode == 200) {
        final analyticsResponse =
            AnalyticsResponse.fromJson(json.decode(response.body));
        return _convertToGraphData(analyticsResponse);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _generateMockData(range);
    }
  }

  List<GraphData> _convertToGraphData(AnalyticsResponse response) {
    final List<GraphData> graphs = [];

    // Extract x values (dates) and format them appropriately
    final formattedDates = _formatDates(response);

    // 1. User Growth
    graphs.add(GraphData(
      title: 'User Growth',
      xValues: formattedDates,
      yValues: _extractYValues(response.data.userGrowth, formattedDates),
      type: 'line',
    ));

    // 2. Post Creation
    graphs.add(GraphData(
      title: 'Content Creation',
      xValues: formattedDates,
      yValues:
          _extractYValues(response.data.contentCreation.posts, formattedDates),
      type: 'bar',
    ));

    // 3. Engagement (Comments)
    graphs.add(GraphData(
      title: 'Comments',
      xValues: formattedDates,
      yValues: _extractYValues(
          response.data.engagementMetrics.comments, formattedDates),
      type: 'line',
    ));

    // 4. Job Postings
    graphs.add(GraphData(
      title: 'Job Postings',
      xValues: formattedDates,
      yValues:
          _extractYValues(response.data.jobMetrics.jobsPosted, formattedDates),
      type: 'bar',
    ));

    return graphs;
  }

  List<String> _formatDates(AnalyticsResponse response) {
    final List<String> dates = [];
    final String interval = response.interval;
    final String period = response.period;

    // Combine all dates from different metrics to get the complete set
    final allDates = [
      ...response.data.userGrowth.map((dp) => dp.date),
      ...response.data.contentCreation.posts.map((dp) => dp.date),
      ...response.data.engagementMetrics.comments.map((dp) => dp.date),
      ...response.data.jobMetrics.jobsPosted.map((dp) => dp.date),
    ];

    // Remove duplicates and sort
    final uniqueDates = Set<String>.from(allDates).toList()..sort();

    // Format dates based on interval
    for (var date in uniqueDates) {
      if (interval == 'day') {
        // Convert YYYY-MM-DD to DD
        final day = DateTime.parse(date).day.toString();
        dates.add(day);
      } else if (interval == 'week') {
        // For week format like "2025-W17", extract the week number
        dates.add('Wk${date.split('-W')[1]}');
      } else if (interval == 'month') {
        // For month format like "2025-05", convert to short month name
        final month = DateTime.parse('${date}-01').month;
        dates.add(_getMonthAbbreviation(month));
      }
    }

    return dates;
  }

  String _getMonthAbbreviation(int month) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return months[month - 1];
  }

  List<double> _extractYValues(
      List<DataPoint> dataPoints, List<String> formattedDates) {
    final Map<String, double> dateValueMap = {};

    for (var dp in dataPoints) {
      String formattedDate;

      // Format the date to match the keys in formattedDates
      if (dp.date.contains('-W')) {
        formattedDate = 'Wk${dp.date.split('-W')[1]}';
      } else if (dp.date.length == 7) {
        // Month format YYYY-MM
        final month = DateTime.parse('${dp.date}-01').month;
        formattedDate = _getMonthAbbreviation(month);
      } else {
        formattedDate = DateTime.parse(dp.date).day.toString();
      }

      dateValueMap[formattedDate] = dp.count.toDouble();
    }

    // Create the y-values list based on the formatted dates
    return formattedDates.map((date) => dateValueMap[date] ?? 0.0).toList();
  }

  // Fallback method that generates mock data if API fails
  List<GraphData> _generateMockData(String range) {
    final random = () => (20 + DateTime.now().microsecond % 80).toDouble();

    List<String> xVals;
    int count;

    switch (range) {
      case '7days':
        xVals = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        count = 7;
        break;
      case '30days':
        xVals = ['Wk1', 'Wk2', 'Wk3', 'Wk4'];
        count = 4;
        break;
      case '90days':
        xVals = ['Q1', 'Q2', 'Q3', 'Q4'];
        count = 4;
        break;
      case '1year':
      default:
        xVals = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
        count = 12;
    }

    return [
      GraphData(
          title: 'User Growth',
          xValues: xVals,
          yValues: List.generate(count, (_) => random()),
          type: 'line'),
      GraphData(
          title: 'Content Creation',
          xValues: xVals,
          yValues: List.generate(count, (_) => random()),
          type: 'bar'),
      GraphData(
          title: 'Comments',
          xValues: xVals,
          yValues: List.generate(count, (_) => random()),
          type: 'line'),
      GraphData(
          title: 'Job Postings',
          xValues: xVals,
          yValues: List.generate(count, (_) => random()),
          type: 'bar'),
    ];
  }
}
