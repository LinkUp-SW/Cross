// search_job_service.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'dart:developer' as developer;

class SearchJobService {
  final BaseService _baseService;

  const SearchJobService(this._baseService);

  // Single method for both search and filter
  Future<Map<String, dynamic>> searchJobsData({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      developer.log('Making API call with parameters: $queryParameters');
      
      // Determine which endpoint to use based on presence of filter params
      bool hasFilters = queryParameters.containsKey('experienceLevel') || 
                        queryParameters.containsKey('location') ||
                        queryParameters.containsKey('minSalary') ||
                        queryParameters.containsKey('maxSalary');
      
      String endpoint = hasFilters ? ExternalEndPoints.filterJobs : ExternalEndPoints.searchJobs;
      
      final response = await _baseService.get(
        endpoint,
        queryParameters: queryParameters,
      );
  
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        
        // Handle various response formats
        List<dynamic> jobsList;
        int totalCount;
        
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('data')) {
          jobsList = decodedResponse['data'] as List;
          totalCount = decodedResponse['total'] ?? jobsList.length;
        } else if (decodedResponse is List) {
          jobsList = decodedResponse;
          totalCount = jobsList.length;
        } else {
          jobsList = [];
          totalCount = 0;
        }
        
        return {
          'jobs': jobsList,
          'total': totalCount,
        };
      }
      
      throw Exception('API returned status code: ${response.statusCode}');
    } catch (e) {
      developer.log('Error in searchJobsData: $e');
      throw Exception('Failed to search or filter jobs: $e');
    }
  }
}

final searchJobServiceProvider = Provider<SearchJobService>(
  (ref) => SearchJobService(ref.read(baseServiceProvider)),
);