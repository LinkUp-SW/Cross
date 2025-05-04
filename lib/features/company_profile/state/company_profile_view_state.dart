// lib/features/company_profile/state/company_profile_view_state.dart

import 'package:link_up/features/company_profile/model/company_profile_model.dart';

class CompanyProfileViewState {
  final CompanyProfileModel? companyProfile;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;

  CompanyProfileViewState({
    this.companyProfile,
    this.errorMessage,
    this.isLoading = false,
    this.isError = false,
  });

  factory CompanyProfileViewState.initial() {
    return CompanyProfileViewState(
      companyProfile: null,
      errorMessage: null,
      isLoading: true,
      isError: false,
    );
  }

  CompanyProfileViewState copyWith({
    CompanyProfileModel? companyProfile,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
  }) {
    return CompanyProfileViewState(
      companyProfile: companyProfile ?? this.companyProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}