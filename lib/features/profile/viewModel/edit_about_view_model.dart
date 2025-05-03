// lib/features/profile/viewModel/edit_about_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'dart:convert'; // For jsonEncode (optional, for logging)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/model/about_model.dart';
import 'package:link_up/features/profile/state/edit_about_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart'; // For refreshing main profile

class EditAboutViewModel extends StateNotifier<EditAboutState> {
  final ProfileService _profileService;
  final Ref _ref;
  final String _userId = InternalEndPoints.userId;

  final TextEditingController aboutController = TextEditingController();
  final int maxAboutChars = 2600; // As per the image

  EditAboutViewModel(this._profileService, this._ref)
      : super(const EditAboutInitial()) {
    _fetchInitialData();

    // Listen to controller changes to update character count or state if needed
    aboutController.addListener(() {
       final currentState = state;
       if (currentState is EditAboutLoaded) {
          // Optionally update state if real-time validation is needed
       } else if (currentState is EditAboutError) {
           // If user starts typing after an error, potentially revert to a loaded state
           // This helps if the error was temporary and they want to retry saving their edits
           state = EditAboutLoaded(
              aboutData: AboutModel(about: aboutController.text, skills: []), // Use current text
              initialAboutExists: currentState.initialAboutExists ?? false, // Preserve initial state knowledge
           );
       }
    });
  }

  /// Fetches the initial 'about' text and skills from the dedicated endpoint.
  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    if (_userId.isEmpty) {
      state = const EditAboutError("User not logged in.");
      return;
    }
    log("[EditAboutViewModel] Fetching initial about data for user ID: $_userId");
    state = const EditAboutLoading();
    try {
      // Fetch data using the dedicated service method
      final aboutData = await _profileService.getUserAboutAndSkills(_userId);
      log("[EditAboutViewModel] Initial data fetched. About: '${aboutData.about}', Skills count: ${aboutData.skills.length}");

      if (mounted) {
         aboutController.text = aboutData.about;
         // Move cursor to end
         aboutController.selection = TextSelection.fromPosition(
            TextPosition(offset: aboutController.text.length),
         );
         // Set the loaded state, indicating whether 'about' text was present
         state = EditAboutLoaded(
            initialAboutExists: aboutData.about.isNotEmpty, // Set the flag here
            aboutData: aboutData
         );
      }
    } catch (e) {
      log("[EditAboutViewModel] Error fetching initial data: $e");
      if (mounted) {
        // Set error state, assuming 'about' didn't exist if fetch failed initially
        state = EditAboutError("Failed to load about section: ${e.toString()}", initialAboutExists: false);
      }
    }
  }

  /// Saves the current 'about' text, choosing between POST (create) and PUT (update).
  Future<void> saveAbout() async {
     if (_userId.isEmpty) {
       final prevText = state is EditAboutLoaded ? (state as EditAboutLoaded).aboutData.about : (state is EditAboutError ? (state as EditAboutError).previousAboutText : null);
       final prevExists = state is EditAboutLoaded ? (state as EditAboutLoaded).initialAboutExists : (state is EditAboutError ? (state as EditAboutError).initialAboutExists : false);
       state = EditAboutError("User not logged in.", previousAboutText: prevText, initialAboutExists: prevExists);
       return;
     }

     final currentState = state;
     String textToSave = aboutController.text.trim();
     String previousTextOnError = '';
     bool wasAboutPresentInitially = false; // Flag to determine POST/PUT

     // Determine initial state and previous text based on current state
     if (currentState is EditAboutLoaded) {
       previousTextOnError = currentState.aboutData.about;
       wasAboutPresentInitially = currentState.initialAboutExists;
     } else if (currentState is EditAboutError) {
        previousTextOnError = currentState.previousAboutText ?? ''; // Use previous text if available
        wasAboutPresentInitially = currentState.initialAboutExists ?? false; // Use stored flag
        textToSave = aboutController.text.trim(); // Use current controller text for retry
        log("[EditAboutViewModel] Retrying save after error. Text to save: '$textToSave'");
     } else {
       log("[EditAboutViewModel] Cannot save from current state: $currentState");
       state = EditAboutError("Cannot save at the moment. Please reload.", previousAboutText: textToSave);
       return;
     }

     // Validate character limit before proceeding
     if (textToSave.length > maxAboutChars) {
        state = EditAboutError(
           "About text cannot exceed $maxAboutChars characters.",
           previousAboutText: textToSave, // Keep current text in controller
           initialAboutExists: wasAboutPresentInitially
        );
        return;
     }

     // Determine if we are creating (POST) or updating (PUT)
     final bool isCreating = !wasAboutPresentInitially;
     state = EditAboutSaving(aboutTextToSave: textToSave, isCreating: isCreating);
     log("[EditAboutViewModel] Saving about data: '$textToSave'. Is Creating: $isCreating");

     try {
       // Call the updated service method, passing the isCreating flag
       final success = await _profileService.updateOrAddUserAbout(
           userId: _userId, aboutText: textToSave, isCreating: isCreating);

       if (success && mounted) {
         log("[EditAboutViewModel] Save successful.");
         state = const EditAboutSuccess();
         // Trigger a refresh of the main profile state to reflect changes globally
         unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile(_userId));
       } else if (mounted) {
         log("[EditAboutViewModel] Save failed (service returned false or non-2xx status).");
         // Revert to error state, preserving the text the user tried to save
         state = EditAboutError("Failed to save about section.", previousAboutText: textToSave, initialAboutExists: wasAboutPresentInitially);
       }
     } catch (e) {
       log("[EditAboutViewModel] Error saving about: $e");
       if (mounted) {
         // Revert to error state on exception
         state = EditAboutError("An error occurred: ${e.toString()}", previousAboutText: textToSave, initialAboutExists: wasAboutPresentInitially);
       }
     }
  }

  @override
  void dispose() {
    log("[EditAboutViewModel] Disposing.");
    aboutController.dispose();
    super.dispose();
  }
}

// Provider definition (remains the same)
final editAboutViewModelProvider =
    StateNotifierProvider.autoDispose<EditAboutViewModel, EditAboutState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return EditAboutViewModel(profileService, ref);
});
