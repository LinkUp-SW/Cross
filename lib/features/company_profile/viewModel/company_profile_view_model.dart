// lib/features/company/viewModel/company_profile_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/company_profile/model/company_profile_model.dart';
import 'package:link_up/features/company_profile/services/company_profile_service.dart';
import 'package:link_up/features/company_profile/state/company_profile_state.dart';
import 'dart:developer' as developer;

class CompanyProfileViewModel extends StateNotifier<CompanyProfileState> {
  final CompanyProfileService _companyProfileService;

  CompanyProfileViewModel(
    this._companyProfileService,
  ) : super(
          CompanyProfileState.initial(),
        );

  Future<void> createCompanyProfile(CompanyProfileModel companyProfile) async {
    developer.log('Creating company profile');
    state = state.copyWith(isLoading: true, isError: false, isSuccess: false, errorMessage: null);

    try {
      final response = await _companyProfileService.createCompanyProfile(
        companyProfile: companyProfile,
      );

      developer.log('Successfully created company profile');
      state = state.copyWith(
        isLoading: false,
        companyProfile: CompanyProfileModel.fromJson(response),
        isError: false,
        isSuccess: true,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error creating company profile: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset the state (useful when navigating away from the form)
  void resetState() {
    state = CompanyProfileState.initial();
  }
}

final companyProfileViewModelProvider =
    StateNotifierProvider<CompanyProfileViewModel, CompanyProfileState>(
  (ref) {
    return CompanyProfileViewModel(
      ref.read(companyProfileServiceProvider),
    );
  },
);