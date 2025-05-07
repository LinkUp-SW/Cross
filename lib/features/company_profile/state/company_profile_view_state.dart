// lib/features/company_profile/state/company_profile_view_state.dart
// Update your state class to include jobs

import 'package:link_up/features/company_profile/model/company_profile_model.dart';
import 'package:link_up/features/company_profile/model/company_jobs_model.dart';

class CompanyProfileViewState {
  final CompanyProfileModel? companyProfile;
  final List<CompanyJobModel> companyJobs;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;
  final bool isJobsLoading;
  final bool isJobsError;
  final String? jobsErrorMessage;

  CompanyProfileViewState({
    this.companyProfile,
    this.companyJobs = const [],
    this.errorMessage,
    this.isLoading = false,
    this.isError = false,
    this.isJobsLoading = false,
    this.isJobsError = false,
    this.jobsErrorMessage,
  });

  factory CompanyProfileViewState.initial() {
    return CompanyProfileViewState(
      companyProfile: null,
      companyJobs: const [],
      errorMessage: null,
      isLoading: true,
      isError: false,
      isJobsLoading: true,
      isJobsError: false,
      jobsErrorMessage: null,
    );
  }

  CompanyProfileViewState copyWith({
    CompanyProfileModel? companyProfile,
    List<CompanyJobModel>? companyJobs,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
    bool? isJobsLoading,
    bool? isJobsError,
    String? jobsErrorMessage,
  }) {
    return CompanyProfileViewState(
      companyProfile: companyProfile ?? this.companyProfile,
      companyJobs: companyJobs ?? this.companyJobs,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isJobsLoading: isJobsLoading ?? this.isJobsLoading,
      isJobsError: isJobsError ?? this.isJobsError,
      jobsErrorMessage: jobsErrorMessage ?? this.jobsErrorMessage,
    );
  }
}