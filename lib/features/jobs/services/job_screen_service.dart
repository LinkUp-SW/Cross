import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/jobs/view/view.dart';
import 'dart:developer' as developer;

class JobScreenService {
  final BaseService _baseService;

  const JobScreenService(this._baseService);

  Future<Map<String, dynamic>> topJobsData({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final fullUrl = '${ExternalEndPoints.baseUrl}${ExternalEndPoints.topJobs}';
      developer.log('Making API call to $fullUrl');
      developer.log('Query parameters: $queryParameters');
      
      final response = await _baseService.get(
        ExternalEndPoints.topJobs,
        queryParameters: queryParameters,
      );
      
      developer.log('Got API response with status: ${response.statusCode}');
      if (response.statusCode != 200) {
        developer.log('Error response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        developer.log('Successful response: $decodedResponse');
        
        // Validate response structure
        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception('Invalid response format: expected Map, got ${decodedResponse.runtimeType}');
        }
        
        if (!decodedResponse.containsKey('data')) {
          throw Exception('Response missing required "data" field');
        }
        
        if (decodedResponse['data'] is! List) {
          throw Exception('Invalid "data" format: expected List, got ${decodedResponse['data'].runtimeType}');
        }
        
        return decodedResponse;
      }
      throw Exception('Failed to get top jobs data: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error in topJobsData: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllJobs({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final fullUrl = '${ExternalEndPoints.baseUrl}${ExternalEndPoints.getJobs}';
      developer.log('Making API call to $fullUrl');
      developer.log('Query parameters: $queryParameters');
      
      final response = await _baseService.get(
        ExternalEndPoints.getJobs,
        queryParameters: queryParameters,
      );
      
      developer.log('Got API response with status: ${response.statusCode}');
      if (response.statusCode != 200) {
        developer.log('Error response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        developer.log('Successful response: $decodedResponse');
        
        // Validate response structure
        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception('Invalid response format: expected Map, got ${decodedResponse.runtimeType}');
        }
        
        if (!decodedResponse.containsKey('data')) {
          throw Exception('Response missing required "data" field');
        }
        
        if (decodedResponse['data'] is! List) {
          throw Exception('Invalid "data" format: expected List, got ${decodedResponse['data'].runtimeType}');
        }
        
        return decodedResponse;
      }
      throw Exception('Failed to get all jobs data: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error in getAllJobs: $e\n$stackTrace');
      rethrow;
    }
  }
}

final jobScreenServiceProvider = Provider<JobScreenService>(
  (ref) {
    return JobScreenService(
      ref.read(baseServiceProvider),
    );
  },
);
