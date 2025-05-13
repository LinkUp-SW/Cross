// lib/features/company/state/company_profile_state.dart

import 'package:link_up/features/company_profile/model/company_profile_model.dart';

class CompanyProfileState {
  final CompanyProfileModel? companyProfile;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;
  final bool isSuccess;

  CompanyProfileState({
    this.companyProfile,
    this.errorMessage,
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
  });

  factory CompanyProfileState.initial() {
    return CompanyProfileState(
      companyProfile: null,
      errorMessage: null,
      isLoading: false,
      isError: false,
      isSuccess: false,
    );
  }

  CompanyProfileState copyWith({
    CompanyProfileModel? companyProfile,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
  }) {
    return CompanyProfileState(
      companyProfile: companyProfile ?? this.companyProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
