import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'dart:developer' as developer;

class JobDetailsService {
  final BaseService _baseService;

  const JobDetailsService(this._baseService);

  Future<Map<String, dynamic>> jobDetailsData({
    required String jobId,
  }) async {
    try {
      developer.log('Fetching job details for ID: $jobId');
      
      // The endpoint has :jobId parameter that needs to be replaced
      final response = await _baseService.get(
        ExternalEndPoints.jobDetails,
        routeParameters: {
          'jobId': jobId,
        },
      );
      
      developer.log('Got response with status: ${response.statusCode}');
      developer.log('Response URL: ${ExternalEndPoints.baseUrl}${ExternalEndPoints.jobDetails.replaceAll(':jobId', jobId)}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');
        
        if (jsonResponse['data'] == null) {
          throw Exception('No data found in response');
        }
        
        return jsonResponse['data'];
      }
      throw Exception('Failed to get job details: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error fetching job details: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> saveJob({required String jobId, required bool isSaved}) async {
    try {
      developer.log('${isSaved ? "Unsaving" : "Saving"} job with ID: $jobId');
      
      final endpoint = isSaved ? ExternalEndPoints.unsaveJob : ExternalEndPoints.saveJob;
      final response = isSaved 
          ? await _baseService.delete(
              endpoint,
              {
                'jobId': jobId,
              },
            )
          : await _baseService.post(
              endpoint,
              routeParameters: {
                'jobId': jobId,
              },
            );
      
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        developer.log('Successfully ${isSaved ? "unsaved" : "saved"} job');
        return;
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Failed to ${isSaved ? "unsave" : "save"} job');
      }
      throw Exception('Failed to ${isSaved ? "unsave" : "save"} job: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error ${isSaved ? "unsaving" : "saving"} job: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<String>> getSavedJobs() async {
    try {
      developer.log('Fetching saved jobs');
      
      final response = await _baseService.get(ExternalEndPoints.getSavedJobs);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] == null) {
          return [];
        }
        
        final List<dynamic> savedJobs = jsonResponse['data'];
        return savedJobs.map((job) => job['_id'].toString()).toList();
      }
      
      throw Exception('Failed to get saved jobs: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error fetching saved jobs: $e\n$stackTrace');
      rethrow;
    }
  }
}

final jobDetailsServiceProvider = Provider<JobDetailsService>(
  (ref) {
    return JobDetailsService(
      ref.read(baseServiceProvider),
    );
  },
);