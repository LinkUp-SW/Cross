// search_job_service.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'dart:developer' as developer;

class SearchJobService {
  final BaseService _baseService;

  const SearchJobService(this._baseService);

 
  Future<Map<String, dynamic>> searchJobsData({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      developer.log('Original parameters: $queryParameters');
      

      final Map<String, String> searchParams = {};
      
      // Required: query parameter
      if (queryParameters.containsKey('query') && queryParameters['query'] != null) {
        searchParams['query'] = queryParameters['query'].toString();
      }
      
    
      if (queryParameters.containsKey('cursor') && queryParameters['cursor'] != null) {
        searchParams['cursor'] = queryParameters['cursor'].toString();
      }
      
      
      if (queryParameters.containsKey('limit') && queryParameters['limit'] != null) {
        final limit = int.tryParse(queryParameters['limit'].toString());
        if (limit != null && limit > 0) {
          searchParams['limit'] = limit.toString();
        }
      }
      
      developer.log('Search parameters: $searchParams');
      
      final response = await _baseService.get(
        ExternalEndPoints.searchJobs,
        queryParameters: searchParams,
      );
      
      developer.log('Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        developer.log('Error response body: ${response.body}');
      }
  
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        developer.log('Success response: $decodedResponse');
        
        
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