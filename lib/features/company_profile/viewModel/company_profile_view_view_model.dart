// lib/features/company_profile/viewModel/company_profile_view_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/company_profile/model/company_profile_model.dart';
import 'package:link_up/features/company_profile/services/company_profile_service.dart';
import 'package:link_up/features/company_profile/state/company_profile_view_state.dart';
import 'dart:developer' as developer;

class CompanyProfileViewViewModel
    extends StateNotifier<CompanyProfileViewState> {
  final CompanyProfileService _companyProfileService;

  CompanyProfileViewViewModel(
    this._companyProfileService,
  ) : super(
          CompanyProfileViewState.initial(),
        );

  Future<void> getCompanyProfile(String companyId) async {
    developer.log('Fetching company profile for ID: $companyId');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final response = await _companyProfileService.getCompanyProfile(
        companyId: companyId,
      );

      final companyProfile = CompanyProfileModel.fromJson(response);

      developer.log('Successfully fetched company profile');
      state = state.copyWith(
        isLoading: false,
        companyProfile: companyProfile,
        isError: false,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error fetching company profile: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // lib/features/company_profile/viewModel/company_profile_view_view_model.dart
// Add this method to your existing CompanyProfileViewViewModel class

  Future<void> getCompanyJobs(String organizationId) async {
    developer.log('Fetching jobs for company ID: $organizationId');
    state = state.copyWith(
        isJobsLoading: true, isJobsError: false, jobsErrorMessage: null);

    try {
      final jobs = await _companyProfileService.getJobsFromCompany(
        organizationId: organizationId,
      );

      developer.log('Successfully fetched ${jobs.length} jobs for company');
      state = state.copyWith(
        isJobsLoading: false,
        companyJobs: jobs,
        isJobsError: false,
        jobsErrorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error fetching jobs for company: $e\n$stackTrace');
      state = state.copyWith(
        isJobsLoading: false,
        isJobsError: true,
        jobsErrorMessage: e.toString(),
      );
    }
  }
}

final companyProfileViewViewModelProvider =
    StateNotifierProvider<CompanyProfileViewViewModel, CompanyProfileViewState>(
  (ref) {
    return CompanyProfileViewViewModel(
      ref.read(companyProfileServiceProvider),
    );
  },
);
