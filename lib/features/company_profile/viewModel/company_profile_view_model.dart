// lib/features/company/viewModel/company_profile_view_model.dart
import 'package:flutter/material.dart'; // Import material
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/company_profile/model/company_profile_model.dart';
import 'package:link_up/features/company_profile/services/company_profile_service.dart';
import 'package:link_up/features/company_profile/state/company_profile_state.dart';
import 'dart:developer' as developer;

class CompanyProfileViewModel extends StateNotifier<CompanyProfileState> {
  final CompanyProfileService _companyProfileService;

  // Controllers for the text fields managed by the ViewModel
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _logoController = TextEditingController(); 
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Expose controllers via getters
  TextEditingController get nameController => _nameController;
  TextEditingController get websiteController => _websiteController;
  TextEditingController get logoController => _logoController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get countryController => _countryController;
  TextEditingController get stateController => _stateController; 
  TextEditingController get cityController => _cityController;

  String _selectedIndustry = 'Information Technology'; 
  String _selectedSize = '1-10 employees';            
  String _selectedType = 'Private company';          

  String get selectedIndustry => _selectedIndustry;
  String get selectedSize => _selectedSize;
  String get selectedType => _selectedType;

  CompanyProfileViewModel(this._companyProfileService) : super(CompanyProfileState.initial()) {
     state = CompanyProfileState(
       countryController: _countryController,
       stateController: _stateController,
       cityController: _cityController,
     );
  }

  void setSelectedIndustry(String value) {
    _selectedIndustry = value;
  }

  void setSelectedSize(String value) {
    _selectedSize = value;
  }

  void setSelectedType(String value) {
    _selectedType = value;
  }

   // Method to update the logo path/URL
   void setLogoUrl(String url) {
     _logoController.text = url;
   }

  Future<void> createCompanyProfile() async {
    developer.log('Creating company profile');
    state = state.copyWith(isLoading: true, isError: false, isSuccess: false, errorMessage: null);

    // Create the model using data from controllers and state
    final companyProfile = CompanyProfileModel(
       name: _nameController.text.trim(),
       website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
       logo: _logoController.text.trim().isNotEmpty ? _logoController.text.trim() : null, // Use logo controller
       description: _descriptionController.text.trim(),
       industry: _selectedIndustry,
       location: LocationModel( // Use LocationModel
         country: _countryController.text.trim(),
         city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
         // state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null, // Add state if needed
       ),
       size: _selectedSize,
       type: _selectedType,
    );


    try {
      final response = await _companyProfileService.createCompanyProfile(
        companyProfile: companyProfile,
      );

      developer.log('Successfully created company profile');
      state = state.copyWith(
        isLoading: false,
        companyProfile: CompanyProfileModel.fromJson(response), // Update state with response
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
        errorMessage: e.toString().replaceFirst('Exception: ', ''), 
      );
    }
  }

  void resetState() {
    state = CompanyProfileState.initial();
    _nameController.clear();
    _websiteController.clear();
    _logoController.clear();
    _descriptionController.clear();
    _countryController.clear();
    _stateController.clear(); 
    _cityController.clear();
    _selectedIndustry = 'Information Technology'; 
    _selectedSize = '1-10 employees';          
    _selectedType = 'Private company';        
     state = CompanyProfileState(
       countryController: _countryController,
       stateController: _stateController,
       cityController: _cityController,
     );

  }

   @override
   void dispose() {
     _nameController.dispose();
     _websiteController.dispose();
     _logoController.dispose();
     _descriptionController.dispose();
     _countryController.dispose();
     _stateController.dispose(); 
     _cityController.dispose();
     super.dispose();
   }
}

final companyProfileViewModelProvider =
    StateNotifierProvider.autoDispose<CompanyProfileViewModel, CompanyProfileState>(
  (ref) {
    final service = ref.read(companyProfileServiceProvider); 
    final viewModel = CompanyProfileViewModel(service);
    return viewModel;
  },
);
