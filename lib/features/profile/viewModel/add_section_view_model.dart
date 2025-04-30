// lib/features/profile/viewModel/add_section_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart'; // Import endpoints
import 'package:link_up/features/profile/services/profile_services.dart'; // Import ProfileService
import 'package:link_up/features/profile/state/add_section_state.dart';
// Removed direct dependency on main ProfileState/ViewModel for this check
// import 'package:link_up/features/profile/state/profile_state.dart' as main_profile;
// import 'package:link_up/features/profile/viewModel/profile_view_model.dart';

class AddSectionViewModel extends StateNotifier<AddSectionState> {
  final Ref _ref;
  // Inject ProfileService
  final ProfileService _profileService;
  final String _userId = InternalEndPoints.userId;
  // StreamSubscription? _profileSubscription; // Removed as we fetch directly now

  // Pass ProfileService in constructor
  AddSectionViewModel(this._ref, this._profileService) : super(const AddSectionState()) {
    // Fetch the about status on initialization
    _checkAboutStatus();
  }

  // New method to fetch specifically the 'about' status
  Future<void> _checkAboutStatus() async {
     if (!mounted) return;
     if (_userId.isEmpty) {
       state = state.copyWith(isLoading: false, error: "User not logged in.");
       return;
     }

     log("[AddSectionViewModel] Checking about status for user ID: $_userId");
     // Keep isLoading true only if it's the initial load
     if (state is AddSectionState && state.isLoading) {
        // Already loading, no need to set again unless retrying
     } else {
        state = state.copyWith(isLoading: true, clearError: true);
     }


     try {
       // Call the service method to get about data
       final aboutData = await _profileService.getUserAboutAndSkills(_userId);
       log("[AddSectionViewModel] Fetched about data. About text length: ${aboutData.about.length}");

       if (mounted) {
         state = state.copyWith(
           isLoading: false,
           // Determine if 'about' exists based on the fetched data
           hasAboutInfo: aboutData.about.isNotEmpty,
           clearError: true,
         );
          log("[AddSectionViewModel] Updated state: isLoading=false, hasAboutInfo=${state.hasAboutInfo}");
       }
     } catch (e) {
       log("[AddSectionViewModel] Error checking about status: $e");
       if (mounted) {
         state = state.copyWith(isLoading: false, error: "Failed to check profile sections: ${e.toString()}");
       }
     }
  }


  // Removed _listenToProfileUpdates and _updateStateFromProfile as they are replaced by _checkAboutStatus

  @override
  void dispose() {
    log("[AddSectionViewModel] Disposing.");
    // _profileSubscription?.cancel(); // No longer needed
    super.dispose();
  }
}

// Update the provider to inject ProfileService
final addSectionViewModelProvider =
    StateNotifierProvider.autoDispose<AddSectionViewModel, AddSectionState>((ref) {
  // Get ProfileService instance
  final profileService = ref.watch(profileServiceProvider);
  return AddSectionViewModel(ref, profileService);
});
