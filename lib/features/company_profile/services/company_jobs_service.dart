import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/company_profile/model/company_jobs_model.dart';
import 'dart:developer' as developer;

class CompanyJobsService {
  final BaseService _baseService;

  const CompanyJobsService(this._baseService);

  Future<List<CompanyJobModel>> getJobsFromCompany({
    required String organizationId,
  }) async {
    try {
      developer.log('=== GET Company Jobs Request ===');
      developer.log('Organization ID: $organizationId');
      
      final endpoint = ExternalEndPoints.getJobsFromCompany.replaceAll(
        ':organization_id',
        organizationId,
      );
      
      developer.log('Endpoint: $endpoint');
      developer.log('Full URL: ${ExternalEndPoints.baseUrl}$endpoint');

      final response = await _baseService.get(
        ExternalEndPoints.getJobsFromCompany,
        routeParameters: {
          ':organization_id': organizationId, // Added colon prefix
        },
      );

      developer.log('=== GET Company Jobs Response ===');
      developer.log('Status Code: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['jobs'] != null && jsonResponse['jobs'] is List) {
          final List<dynamic> jobsJson = jsonResponse['jobs'];
          developer.log('Found ${jobsJson.length} jobs');
          
          return jobsJson
              .map((job) => CompanyJobModel.fromJson(job as Map<String, dynamic>))
              .toList();
        }
        
        developer.log('No jobs found in response');
        return [];
      }

      if (response.statusCode == 404) {
        developer.log('No jobs found for organization: $organizationId');
        return [];
      }

      throw Exception('Failed to get jobs. Status code: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('=== Company Jobs Error ===');
      developer.log('Error Type: ${e.runtimeType}');
      developer.log('Error Message: $e');
      developer.log('Stack Trace: $stackTrace');
      rethrow;
    }
  }
}