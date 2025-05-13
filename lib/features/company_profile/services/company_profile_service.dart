// lib/features/company_profile/services/company_profile_service.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/company_profile/model/company_jobs_model.dart';
import 'package:link_up/features/company_profile/model/company_profile_model.dart';
import 'dart:developer' as developer;

class CompanyProfileService {
  final BaseService _baseService;

  const CompanyProfileService(this._baseService);

  Future<Map<String, dynamic>> createCompanyProfile({
    required CompanyProfileModel companyProfile,
  }) async {
    try {
      developer.log('Creating company profile');

      final response = await _baseService.post(
        ExternalEndPoints.createCompanyProfile,
        body: companyProfile.toJson(),
      );

      developer.log('Got response with status: ${response.statusCode}');
      developer.log(
          'Response URL: ${ExternalEndPoints.baseUrl}${ExternalEndPoints.createCompanyProfile}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');

        // Check if the response contains companyProfile instead of data
        if (jsonResponse['companyProfile'] != null) {
          return jsonResponse['companyProfile'];
        } else if (jsonResponse['data'] != null) {
          return jsonResponse['data'];
        } else {
          throw Exception('No company profile data found in response');
        }
      }
      throw Exception(
          'Failed to create company profile: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error creating company profile: $e\n$stackTrace');
      rethrow;
    }
  }
// lib/features/company_profile/services/company_profile_service.dart
// Add this method to your existing CompanyProfileService class

  Future<List<CompanyJobModel>> getJobsFromCompany({
    required String organizationId,
  }) async {
    try {
      developer.log('Fetching jobs for company ID: $organizationId');

      final response = await _baseService.get(
        ExternalEndPoints.getJobsFromCompany,
        routeParameters: {
          'organization_id': organizationId,
        },
      );

      developer.log('Got response with status: ${response.statusCode}');
      developer.log(
          'Response URL: ${ExternalEndPoints.baseUrl}${ExternalEndPoints.getJobsFromCompany.replaceAll(':organization_id', organizationId)}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');

        if (jsonResponse['jobs'] != null) {
          final List<dynamic> jobsJson = jsonResponse['jobs'];
          return jobsJson.map((job) => CompanyJobModel.fromJson(job)).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return []; // Return empty list for no jobs found
      } else {
        throw Exception(
            'Failed to get jobs for company: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching jobs for company: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCompanyProfile({
    required String companyId,
  }) async {
    try {
      developer.log('Fetching company profile for ID: $companyId');

      final response = await _baseService.get(
        ExternalEndPoints.getCompanyProfile,
        routeParameters: {
          'companyId': companyId,
        },
      );

      developer.log('Got response with status: ${response.statusCode}');
      developer.log(
          'Response URL: ${ExternalEndPoints.baseUrl}${ExternalEndPoints.getCompanyProfile.replaceAll(':companyId', companyId)}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');

        if (jsonResponse['companyProfile'] != null) {
          return jsonResponse['companyProfile'];
        } else if (jsonResponse['data'] != null) {
          return jsonResponse['data'];
        } else {
          throw Exception('No company profile data found in response');
        }
      }
      throw Exception('Failed to get company profile: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error fetching company profile: $e\n$stackTrace');
      rethrow;
    }
  }
}

final companyProfileServiceProvider = Provider<CompanyProfileService>(
  (ref) {
    return CompanyProfileService(
      ref.read(baseServiceProvider),
    );
  },
);
