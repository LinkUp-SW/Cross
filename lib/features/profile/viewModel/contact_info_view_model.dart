import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/model/contact_info_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/contact_info_state.dart';

class ContactInfoViewModel extends StateNotifier<EditContactInfoState> {
  final ProfileService _profileService;
  final String _userId = InternalEndPoints.userId;

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  String? selectedPhoneType;
  DateTime? _selectedBirthday;

  Map<String, dynamic> _originalBioData = {};

  ContactInfoViewModel(this._profileService)
      : super(const EditContactInfoInitial()) {
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (_userId.isEmpty) {
      state = const EditContactInfoError("User not logged in.");
      return;
    }
    log("ViewModel: Fetching initial data for user ID: $_userId");
    state = const EditContactInfoLoading();
    try {
      final fullProfileJson = await _profileService.fetchFullUserProfileJson(_userId);
      _originalBioData = fullProfileJson['bio'] ?? {};

      // --- Construct Profile URL ---
      final firstName = _originalBioData['first_name'] as String?;
      final lastName = _originalBioData['last_name'] as String?;

      if (firstName != null && lastName != null && firstName.isNotEmpty && lastName.isNotEmpty && _userId.isNotEmpty) {
        final formattedFirstName = firstName.toLowerCase().trim();
        final formattedLastName = lastName.toLowerCase().trim();
        // Replace spaces with hyphens if necessary, although LinkedIn usually concatenates or uses a specific format.
        // Let's assume simple lowercase concatenation based on the example.
        // Adjust formatting logic here if needed based on actual LinkedIn URL structures.
        final constructedUrl = "https://www.linkedin.com/in/$formattedFirstName-$formattedLastName-$_userId/";
        InternalEndPoints.profileUrl = constructedUrl; // Update the static variable
         log("ViewModel: Constructed and updated InternalEndPoints.profileUrl: ${InternalEndPoints.profileUrl}");
      } else {
         log("ViewModel: Could not construct profile URL. Missing data: F:$firstName, L:$lastName, ID:$_userId");
         // Keep existing InternalEndPoints.profileUrl or set a default/empty string
      }
      // --- End Construct Profile URL ---


      final contactInfoJson = _originalBioData['contact_info'] as Map<String, dynamic>?;
      final contactInfo = contactInfoJson != null
          ? ContactInfoModel.fromJson(contactInfoJson)
          : ContactInfoModel.initial();

      log("ViewModel: Initial data fetched. ContactInfo: ${contactInfo.toString()}");

      phoneNumberController.text = contactInfo.phoneNumber ?? '';
      addressController.text = contactInfo.address ?? '';
      websiteController.text = contactInfo.website ?? '';
      selectedPhoneType = contactInfo.phoneType;
      _selectedBirthday = contactInfo.birthday;
      birthdayController.text = contactInfo.birthday != null
          ? DateFormat('yyyy-MM-dd').format(contactInfo.birthday!)
          : '';

      if (mounted) {
         state = EditContactInfoLoaded(
            contactInfo: contactInfo,
            originalBioData: _originalBioData,
         );
      }
    } catch (e) {
      log("ViewModel: Error fetching initial data: $e");
      if (mounted) {
         state = EditContactInfoError("Failed to load contact info: ${e.toString()}");
      }
    }
  }

  void setPhoneType(String? type) {
    if (state is EditContactInfoLoaded || state is EditContactInfoSaving || state is EditContactInfoError) {
      selectedPhoneType = type;
    }
  }

  void setBirthday(DateTime? date) {
     if (state is EditContactInfoLoaded || state is EditContactInfoSaving || state is EditContactInfoError) {
      _selectedBirthday = date;
      birthdayController.text = date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
     }
  }

  Future<void> saveContactInfo() async {
     if (_userId.isEmpty) {
       state = const EditContactInfoError("User not logged in.");
       return;
     }

     ContactInfoModel currentContactInfo;
     Map<String, dynamic> currentOriginalBioData;

     final currentState = state;
     if (currentState is EditContactInfoLoaded) {
       currentContactInfo = currentState.contactInfo;
       currentOriginalBioData = currentState.originalBioData;
     } else if (currentState is EditContactInfoError && currentState.previousContactInfo != null) {
       currentContactInfo = currentState.previousContactInfo!;
       currentOriginalBioData = currentState.originalBioData ?? _originalBioData;
       log("Attempting save after error state.");
     } else {
       log("ViewModel: Cannot save from current state: $currentState");
       return;
     }

     final updatedInfo = ContactInfoModel(
       phoneNumber: phoneNumberController.text.isNotEmpty ? phoneNumberController.text : null,
       countryCode: currentOriginalBioData['contact_info']?['country_code'],
       phoneType: selectedPhoneType,
       address: addressController.text.isNotEmpty ? addressController.text : null,
       birthday: _selectedBirthday,
       website: websiteController.text.isNotEmpty ? websiteController.text : null,
     );

     log("ViewModel: Preparing to save. Updated ContactInfo: ${updatedInfo.toJson()}");
     log("ViewModel: Using originalBioData: $currentOriginalBioData");

     state = EditContactInfoSaving(
       contactInfo: updatedInfo,
       originalBioData: currentOriginalBioData,
     );

     try {
       final success = await _profileService.updateContactInfo(
         userId: _userId,
         updatedContactInfo: updatedInfo,
         originalBio: currentOriginalBioData,
       );

       if (success && mounted) {
         log("ViewModel: Save successful.");
         state = const EditContactInfoSuccess();
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
              state = EditContactInfoLoaded(
                 contactInfo: updatedInfo,
                 originalBioData: currentOriginalBioData,
              );
          }
       } else if (mounted) {
         log("ViewModel: Save failed (service returned false).");
         state = EditContactInfoError(
           "Failed to save contact info.",
           previousContactInfo: updatedInfo,
           originalBioData: currentOriginalBioData,
         );
       }
     } catch (e) {
       log("ViewModel: Error saving data: $e");
       if (mounted) {
         state = EditContactInfoError(
           "An error occurred during save: ${e.toString()}",
           previousContactInfo: updatedInfo,
           originalBioData: currentOriginalBioData,
         );
       }
     }
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}

final contactInfoViewModelProvider =
    StateNotifierProvider.autoDispose<ContactInfoViewModel, EditContactInfoState>((ref) {
  final service = ref.watch(profileServiceProvider);
  return ContactInfoViewModel(service);
});