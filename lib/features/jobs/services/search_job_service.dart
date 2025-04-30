import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'dart:developer' as developer;

class SearchJobService {
  final BaseService _baseService;

  const SearchJobService(this._baseService);

  Future<Map<String, dynamic>> searchJobsData({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final fullUrl = '${ExternalEndPoints.baseUrl}${ExternalEndPoints.searchJobs}';
      developer.log('Making API call to $fullUrl');
      developer.log('Query parameters: $queryParameters');

      // Ensure query is trimmed and properly formatted
      if (queryParameters != null && queryParameters.containsKey('query')) {
        String searchQuery = queryParameters['query'].toString().trim();
        developer.log('Searching for: "$searchQuery"');
        
        // Update the query parameter with the trimmed value
        queryParameters['query'] = searchQuery;
      }

      final response = await _baseService.get(
        ExternalEndPoints.searchJobs,
        queryParameters: queryParameters,
      );
  
      developer.log('Got API response with status: ${response.statusCode}');
      if (response.statusCode != 200) {
        developer.log('Error response body: ${response.body}');
      }
  
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        developer.log('Successful response: $decodedResponse');
        
        // Handle different response formats
        if (decodedResponse is Map<String, dynamic>) {
          // If it's already a map, use it directly
          if (decodedResponse.containsKey('data')) {
            final result = {
              'jobs': decodedResponse['data'] ?? [],
              'total': decodedResponse['total'] ?? 0,
            };
            developer.log('Processed map response, found ${result['total']} jobs');
            return result;
          }
          developer.log('Response is map but does not contain data key: ${decodedResponse.keys}');
          return decodedResponse;
        } 
        else if (decodedResponse is List) {
          // If it's a list, convert it to the expected format
          final result = {
            'jobs': decodedResponse,
            'total': decodedResponse.length,
          };
          developer.log('Processed list response, found ${result['total']} jobs');
          return result;
        }
        
        developer.log('Unexpected response format: ${decodedResponse.runtimeType}');
        // Default fallback for unexpected formats
        return {
          'jobs': [],
          'total': 0,
        };
      }
      throw Exception('Unexpected response status: ${response.statusCode}');
    } catch (e) {
      developer.log('Error in searchJobsData: $e');
      throw Exception('Error in searchJobsData: $e');
    }
  }
}

final searchJobServiceProvider = Provider<SearchJobService>(
  (ref) {
    return SearchJobService(
      ref.read(baseServiceProvider),
    );
  },
);


































  
  


 























