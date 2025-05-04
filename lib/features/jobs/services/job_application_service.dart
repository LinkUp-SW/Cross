import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/jobs/model/job_application_submit_model.dart';
import 'package:link_up/features/jobs/model/applied_job_model.dart';
import 'dart:developer' as developer;

class JobApplicationService {
  final BaseService _baseService;

  const JobApplicationService(this._baseService);

  Future<Map<String, dynamic>> getApplicationUserData() async {
    try {
      developer.log('Fetching job application user data');

      final response = await _baseService.get(
        ExternalEndPoints.applyForJob,
      );

      developer.log('Got response with status: ${response.statusCode}');
      developer.log(
          'Response URL: ${ExternalEndPoints.baseUrl}${ExternalEndPoints.applyForJob}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');

        if (jsonResponse['data'] == null) {
          throw Exception('No data found in response');
        }

        return jsonResponse['data'];
      }
      throw Exception(
          'Failed to get application user data: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error fetching application user data: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitJobApplication({
    required String jobId,
    required JobApplicationSubmitModel applicationData,
  }) async {
    try {
      developer.log('Submitting job application for job ID: $jobId');

      final endpoint =
          ExternalEndPoints.createJobApplication.replaceAll(':job_id', jobId);

      final response = await _baseService.post(
        endpoint,
        body: applicationData.toJson(),
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Successfully submitted job application');
        return jsonResponse;
      }

      if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        throw Exception(
            responseBody['message'] ?? 'Failed to submit application');
      }

      throw Exception(
          'Failed to submit job application: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error submitting job application: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<AppliedJobModel>> getAppliedJobs() async {
    try {
      developer.log('Fetching user\'s applied jobs');

      final response = await _baseService.get(ExternalEndPoints.getAppliedJobs);

      developer.log('Got response with status: ${response.statusCode}');
      developer.log(
          'Response URL: ${ExternalEndPoints.baseUrl}${ExternalEndPoints.getAppliedJobs}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');

        if (jsonResponse['data'] == null) {
          return [];
        }

        final List<dynamic> jobsData = jsonResponse['data'];
        final List<AppliedJobModel> appliedJobs =
            jobsData.map((job) => AppliedJobModel.fromJson(job)).toList();

        return appliedJobs;
      }
      throw Exception('Failed to get applied jobs: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error fetching applied jobs: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<dynamic>> getJobApplications(String jobId) async {
    try {
      developer.log('Fetching applications for job ID: $jobId');

      final endpoint =
          ExternalEndPoints.getJobApplications.replaceAll(':job_id', jobId);

      final response = await _baseService.get(endpoint);

      developer.log('Got response with status: ${response.statusCode}');
      developer.log('Response URL: ${ExternalEndPoints.baseUrl}$endpoint');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Response body: ${response.body}');

        if (jsonResponse['data'] == null) {
          return [];
        }

        return jsonResponse['data'];
      }
      throw Exception('Failed to get job applications: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error fetching job applications: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      developer
          .log('Updating application status for ID: $applicationId to $status');

      final endpoint = ExternalEndPoints.updateJobApplicationStatus
          .replaceAll('{application_id}', applicationId);

      // Fixed: Directly pass the body as Map<String, dynamic> to match BaseService.put signature
      final response = await _baseService.put(
        endpoint,
        body: {
          'application_status': status
        }, // This matches the signature in BaseService
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Successfully updated application status');
        return jsonResponse;
      }

      if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        throw Exception(
            responseBody['message'] ?? 'Failed to update application status');
      }

      throw Exception(
          'Failed to update application status: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('Error updating application status: $e\n$stackTrace');
      rethrow;
    }
  }
}

final jobApplicationServiceProvider = Provider<JobApplicationService>(
  (ref) {
    return JobApplicationService(
      ref.read(baseServiceProvider),
    );
  },
);
