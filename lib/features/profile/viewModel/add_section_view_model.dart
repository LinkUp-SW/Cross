// lib/features/profile/viewModel/add_section_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_section_state.dart';
import 'package:link_up/features/profile/model/about_model.dart'; // <-- Import AboutModel

class AddSectionViewModel extends StateNotifier<AddSectionState> {
  final Ref _ref;
  final ProfileService _profileService;
  final String _userId = InternalEndPoints.userId;

  AddSectionViewModel(this._ref, this._profileService) : super(const AddSectionState()) {
    refreshStatus();
  }

  /// Fetches status for sections that can be hidden (About, Resume).
  Future<void> refreshStatus() async {
     if (!mounted) return;
     if (_userId.isEmpty) {
       state = state.copyWith(isLoading: false, error: "User not logged in.", hasAboutInfo: false, hasResume: false);
       return;
     }

     log("[AddSectionViewModel] Refreshing profile status for user ID: $_userId");
     state = state.copyWith(isLoading: true, clearError: true);

     try {
       final aboutFuture = _profileService.getUserAboutAndSkills(_userId);
       final resumeUrlFuture = _profileService.getCurrentResumeUrl(_userId);

       // Future.wait returns List<Object?>
       final List<Object?> results = await Future.wait([aboutFuture, resumeUrlFuture]);

       // --- FIX STARTS HERE ---
       // Safely cast results to their expected types
       final AboutModel? aboutData = results[0] is AboutModel ? results[0] as AboutModel : null;
       final String? resumeUrl = results[1] is String ? results[1] as String : null;
       // --- FIX ENDS HERE ---


       if (mounted) {
          // Check results using the correctly typed variables
          // Use null-aware access on aboutData
          final bool aboutExists = aboutData?.about.isNotEmpty ?? false;
          final bool resumeExists = resumeUrl != null && resumeUrl.isNotEmpty;

          log("[AddSectionViewModel] Status Fetched. About exists: $aboutExists, Resume exists: $resumeExists");

          state = state.copyWith(
             isLoading: false,
             hasAboutInfo: aboutExists,
             hasResume: resumeExists,
             clearError: true,
          );
          log("[AddSectionViewModel] Updated state: isLoading=${state.isLoading}, hasAboutInfo=${state.hasAboutInfo}, hasResume=${state.hasResume}");
       }
     } catch (e) {
       log("[AddSectionViewModel] Error refreshing profile status: $e");
       if (mounted) {
         state = state.copyWith(isLoading: false, error: "Failed to check profile sections: ${e.toString()}", hasAboutInfo: false, hasResume: false);
       }
     }
  }

  @override
  void dispose() {
    log("[AddSectionViewModel] Disposing.");
    super.dispose();
  }
}

// Provider definition remains the same
final addSectionViewModelProvider =
    StateNotifierProvider.autoDispose<AddSectionViewModel, AddSectionState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddSectionViewModel(ref, profileService);
});