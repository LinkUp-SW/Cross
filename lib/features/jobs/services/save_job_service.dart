import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';


class SaveJobService {
  final BaseService _baseService;

  const SaveJobService(this._baseService);

  Future<Map<String, dynamic>> saveJob({
    Map<String, dynamic>? queryParameters, required String jobId,
  }) async {
    try {
      final fullUrl = '${ExternalEndPoints.baseUrl}${ExternalEndPoints.saveJob}';
      developer.log('Making API call to $fullUrl');
      developer.log('Query parameters: $queryParameters');

      final response = await _baseService.post(
        ExternalEndPoints.saveJob,
        queryParameters: queryParameters,
      );
      
      developer.log('Got API response with status: ${response.statusCode}');
      if (response.statusCode != 200) {
        developer.log('Error response body: ${response.body}');
        throw Exception('Failed to save job');
      }
      
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        developer.log('Successful response: $decodedResponse');
        
        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception('Invalid response format: expected Map, got ${decodedResponse.runtimeType}');
        }
        
        if (!decodedResponse.containsKey('data')) {
          throw Exception('Response missing required "data" field');
        }

        if (decodedResponse['data'] is! Map<String, dynamic>) {
          throw Exception('Invalid "data" format: expected Map, got ${decodedResponse['data'].runtimeType}');
        } 
        
        return decodedResponse;       
      }
      throw Exception('Failed to get save job data: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error in saveJob: $e\n$stackTrace');
      rethrow;
    }
  }
}
  final saveJobServiceProvider = Provider<SaveJobService>(
    (ref) {
      return SaveJobService(
        ref.read(baseServiceProvider),
      );
    },
  );

 

      
    
