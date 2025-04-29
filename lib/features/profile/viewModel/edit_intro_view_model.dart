import 'dart:developer';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/model/edit_intro_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/edit_intro_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';

class EditIntroViewModel extends StateNotifier<EditIntroState> {
  final ProfileService _profileService;
  final Ref _ref;
  final String _userId = InternalEndPoints.userId;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController headlineController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  Map<String, dynamic> _originalBioData = {};

  EditIntroViewModel(this._profileService, this._ref)
      : super(const EditIntroInitial()) {
    _fetchInitialData();

    firstNameController.addListener(() => _updateFormData((current) => current.copyWith(firstName: firstNameController.text)));
    lastNameController.addListener(() => _updateFormData((current) => current.copyWith(lastName: lastNameController.text)));
    headlineController.addListener(() => _updateFormData((current) => current.copyWith(headline: headlineController.text)));
    websiteController.addListener(() => _updateFormData((current) => current.copyWith(website: websiteController.text)));
  }

  Future<void> _fetchInitialData() async {
    if (_userId.isEmpty) {
      state = const EditIntroError("User not logged in.");
      return;
    }
    log("EditIntroViewModel: Fetching initial data for user ID: $_userId");
    state = const EditIntroLoading();
    try {
      final fullProfileJson = await _profileService.fetchFullUserProfileJson(_userId);
      _originalBioData = Map<String, dynamic>.from(fullProfileJson['bio'] ?? {});
      final bio = _originalBioData; // Use the already fetched bio
      final List<EducationModel> educations = await _profileService.getUserEducation(_userId);

      final location = bio['location'] as Map<String, dynamic>? ?? {};

      firstNameController.text = bio['first_name'] as String? ?? '';
      lastNameController.text = bio['last_name'] as String? ?? '';
      headlineController.text = bio['headline'] as String? ?? '';
      countryController.text = location['country_region'] as String? ?? '';
      cityController.text = location['city'] as String? ?? '';
      websiteController.text = bio['website'] as String? ?? '';

      final initialFormData = EditIntroModel(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        headline: headlineController.text,
        countryRegion: countryController.text,
        city: cityController.text,
        availableEducations: educations, // Assign fetched educations
        selectedEducationId: null, 
        showEducationInIntro: false,
        website: websiteController.text,
      );

      log("EditIntroViewModel: Initial data loaded. FormData: ${initialFormData.toString()}");
      if (mounted) {
         state = EditIntroDataState(formData: initialFormData, originalBioData: _originalBioData);
      }
    } catch (e) {
       log("EditIntroViewModel: Error fetching initial data: $e");
       if (mounted) {
         state = EditIntroError("Failed to load intro data: ${e.toString()}", originalBioData: _originalBioData);
       }
    }
  }

  void _updateFormData(EditIntroModel Function(EditIntroModel current) updater) {
    final currentState = state;

    if (currentState is EditIntroDataState) {
       final updatedFormData = updater(currentState.formData);
       state = EditIntroDataState(
           formData: updatedFormData,
           originalBioData: currentState.originalBioData,
       );
    } else if (currentState is EditIntroError && currentState.previousFormData != null) {
        final updatedFormData = updater(currentState.previousFormData!);
        state = EditIntroError(
           currentState.message,
           previousFormData: updatedFormData,
           originalBioData: currentState.originalBioData,
        );
    } else if (currentState is EditIntroSaving) {
       final updatedFormData = updater(currentState.formData);
       state = EditIntroSaving(
           formData: updatedFormData,
           originalBioData: currentState.originalBioData,
       );
    }
  }

  void setCountry(String value) {
     if (countryController.text != value) {
        countryController.text = value;
     }
     _updateFormData((current) => current.copyWith(countryRegion: value));
     log("ViewModel: Country set to $value");
  }

  void setCity(String value) {
      if (cityController.text != value) {
         cityController.text = value;
      }
    _updateFormData((current) => current.copyWith(city: value));
    log("ViewModel: City set to $value");
  }

  void setSelectedEducation(String? educationId) {
      _updateFormData((current) => current.copyWith(selectedEducationId: educationId));
  }

  void toggleShowEducation(bool value) {
      _updateFormData((current) => current.copyWith(showEducationInIntro: value));
  }

  Future<void> refetchForRetry() async {
     await _fetchInitialData();
  }

  void setWebsite(String value) {
     _updateFormData((current) => current.copyWith(website: value));
  }

  Future<void> saveIntro() async {
    if (_userId.isEmpty) {
      state = const EditIntroError("User not logged in.");
      return;
    }

    EditIntroModel currentFormData;
    Map<String, dynamic> originalDataForSave;

     final currentState = state;
     if (currentState is EditIntroDataState) {
       currentFormData = currentState.formData;
       originalDataForSave = currentState.originalBioData;
     } else if (currentState is EditIntroError && currentState.previousFormData != null) {
        currentFormData = currentState.previousFormData!;
        originalDataForSave = currentState.originalBioData ?? _originalBioData;
     }
     else {
       return;
     }

    if (currentFormData.firstName.trim().isEmpty) {
      state = EditIntroError("First name is required.", previousFormData: currentFormData, originalBioData: originalDataForSave);
      return;
    }
    if (currentFormData.lastName.trim().isEmpty) {
       state = EditIntroError("Last name is required.", previousFormData: currentFormData, originalBioData: originalDataForSave);
       return;
    }
     if (currentFormData.headline.trim().isEmpty) {
       state = EditIntroError("Headline is required.", previousFormData: currentFormData, originalBioData: originalDataForSave);
       return;
     }
      if (currentFormData.countryRegion == null || currentFormData.countryRegion!.trim().isEmpty) {
        state = EditIntroError("Country/Region is required.", previousFormData: currentFormData, originalBioData: originalDataForSave);
        return;
      }

    state = EditIntroSaving(formData: currentFormData, originalBioData: originalDataForSave);

    Map<String, dynamic> updatedBio = Map<String, dynamic>.from(originalDataForSave);
    updatedBio['first_name'] = currentFormData.firstName.trim();
    updatedBio['last_name'] = currentFormData.lastName.trim();
    updatedBio['headline'] = currentFormData.headline.trim();
    Map<String, dynamic> location = Map<String, dynamic>.from(updatedBio['location'] ?? {});
    location['country_region'] = currentFormData.countryRegion!.trim();
    location['city'] = currentFormData.city?.trim().isNotEmpty ?? false ? currentFormData.city!.trim() : null;
    updatedBio['location'] = location;
    updatedBio['website'] = currentFormData.website?.trim().isNotEmpty ?? false
                           ? currentFormData.website!.trim()
                           : null;

    final Map<String, dynamic> requestBody = {'bio': updatedBio};
    log("EditIntroViewModel: Saving intro data: ${jsonEncode(requestBody)}");

    try {
      const String endpoint = 'api/v1/user/update-user-profile';
      final response = await _profileService.put(endpoint, requestBody);

      if ((response.statusCode == 200 || response.statusCode == 204) && mounted) {
        log("EditIntroViewModel: Save successful.");
        state = const EditIntroSuccess();
        await _ref.read(profileViewModelProvider.notifier).fetchUserProfile(_userId);
      } else if (mounted) {
        log("EditIntroViewModel: Save failed. Status: ${response.statusCode}, Body: ${response.body}");
        String errorMessage = 'Failed to save intro';
         try {
            final errorJson = jsonDecode(response.body);
            errorMessage = errorJson['message'] ?? errorMessage;
         } catch (_) {}
        state = EditIntroError(errorMessage, previousFormData: currentFormData, originalBioData: originalDataForSave);
      }
    } catch (e) {
      log("EditIntroViewModel: Error saving intro: $e");
      if (mounted) {
        state = EditIntroError("An error occurred: ${e.toString()}", previousFormData: currentFormData, originalBioData: originalDataForSave);
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    headlineController.dispose();
    countryController.dispose();
    cityController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}

final editIntroViewModelProvider =
    StateNotifierProvider.autoDispose<EditIntroViewModel, EditIntroState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return EditIntroViewModel(profileService, ref);
});