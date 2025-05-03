/*import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/jobs/model/job_filter_model.dart';
import 'dart:developer' as developer;

class JobFilterService {
  final BaseService _baseService;

  const JobFilterService(this._baseService);

  Future<Map<String, dynamic>> filterJobs({
    required JobFilterModel filter,
    required String searchQuery,
    String? cursor,
    int limit = 10,
  }) async {
    try {
      // Get filter parameters and remove null values
      final filterParams = filter.toJson();
      developer.log('Initial filter parameters: $filterParams');
      
      // Ensure at least one filter is provided
      if (filterParams.isEmpty) {
        throw Exception('At least one filter must be provided');
      }
      
      // Format parameters exactly like the Swagger example
      final Map<String, String> queryParams = {};
      
      if (filterParams.containsKey('location')) {
        queryParams['location'] = filterParams['location'].toString();
      }
      
      if (filterParams.containsKey('experienceLevel')) {
        final levels = filterParams['experienceLevel'] as List<String>;
        if (levels.isNotEmpty) {
          // Send as JSON array string to match Swagger example
          queryParams['experienceLevel'] = jsonEncode(levels);
        }
      }
      
      if (filterParams.containsKey('minSalary')) {
        queryParams['minSalary'] = filterParams['minSalary'].toString();
      }
      
      if (filterParams.containsKey('maxSalary')) {
        queryParams['maxSalary'] = filterParams['maxSalary'].toString();
      }
      
      developer.log('Sending filter request with query parameters: $queryParams');
      
      final response = await _baseService.get(
        ExternalEndPoints.filterJobs,
        queryParameters: queryParams,
      );
      
      developer.log('Filter response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Filter response body: ${response.body}');
        
        // Check response format and extract job data
        List<dynamic> jobsList = [];
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          jobsList = jsonResponse['data'] as List;
        } else if (jsonResponse.containsKey('jobs') && jsonResponse['jobs'] is List) {
          jobsList = jsonResponse['jobs'] as List;
        } else if (jsonResponse is List) {
          jobsList = jsonResponse;
        }
        
        developer.log('Found ${jobsList.length} jobs in filter response');
        
        final totalJobs = jsonResponse['total'] ?? jobsList.length;
        
        return {
          'jobs': jobsList,
          'total': totalJobs,
        };
      } else {
        developer.log('Error response: ${response.body}');
        throw Exception('Failed to filter jobs: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Error filtering jobs: $e\n$stackTrace');
      throw Exception('Error filtering jobs: $e');
    }
  }
}

final jobFilterServiceProvider = Provider<JobFilterService>(
  (ref) {
    return JobFilterService(
      ref.read(baseServiceProvider),
    );
  },
);*/