// lib/features/company/state/company_profile_state.dart
import 'package:flutter/material.dart';
import 'package:link_up/features/company_profile/model/company_profile_model.dart';

class CompanyProfileState {
  final CompanyProfileModel? companyProfile;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;
  final bool isSuccess;
  final TextEditingController countryController;
  final TextEditingController stateController;
  final TextEditingController cityController;


  CompanyProfileState({
    this.companyProfile,
    this.errorMessage,
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    required this.countryController,
    required this.stateController,
    required this.cityController,
  });

  factory CompanyProfileState.initial() {
    return CompanyProfileState(
      companyProfile: null,
      errorMessage: null,
      isLoading: false,
      isError: false,
      isSuccess: false,
      countryController: TextEditingController(),
      stateController: TextEditingController(),
      cityController: TextEditingController()

        );
  }

  CompanyProfileState copyWith({
    CompanyProfileModel? companyProfile,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    TextEditingController? countryController,
    TextEditingController? stateController,
    TextEditingController? cityController
  }) {
    return CompanyProfileState(
      companyProfile: companyProfile ?? this.companyProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
      countryController: this.countryController,
      stateController: this.stateController,
      cityController: this.cityController
    );
  }
}