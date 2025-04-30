// lib/features/profile/viewModel/add_section_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/state/add_section_state.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';

class AddSectionViewModel extends StateNotifier<AddSectionState> {
  final Ref _ref;
  StreamSubscription? _profileSubscription;

  AddSectionViewModel(this._ref) : super(const AddSectionState()) {
    _listenToProfileUpdates();
    // Trigger initial check in case profile is already loaded
    _updateStateFromProfile(_ref.read(profileViewModelProvider));
  }

  void _listenToProfileUpdates() {
    // Cancel previous subscription if exists
    _profileSubscription?.cancel();
    // Listen to the main profile view model using ref.listen
    // No need to store the subscription manually here, ref.listen handles it.
    _ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
       log("[AddSectionViewModel] Profile state changed: $next");
      _updateStateFromProfile(next);
    });
  }

  void _updateStateFromProfile(ProfileState profileState) {
    if (!mounted) return; // Ensure the notifier is still mounted

    if (profileState is ProfileLoaded) {
      final userProfile = profileState.userProfile;
      log("[AddSectionViewModel] Updating state from ProfileLoaded. Headline: '${userProfile.headline}'");
      state = state.copyWith(
        isLoading: false,
        // Assuming headline represents the "about" info.
        // If you add a separate 'about' field to UserProfile, check that field instead.
        hasAboutInfo: userProfile.headline.isNotEmpty,
        clearError: true, // Clear any previous error
      );
    } else if (profileState is ProfileLoading || profileState is ProfileInitial) {
       log("[AddSectionViewModel] Profile is loading or initial.");
      // Keep loading true if profile isn't loaded yet
      // Avoid resetting hasAboutInfo if it was already determined
      state = state.copyWith(isLoading: true, clearError: true);
    } else if (profileState is ProfileError) {
       log("[AddSectionViewModel] Profile error: ${profileState.message}");
      state = state.copyWith(isLoading: false, error: profileState.message);
    }
  }

  // Override dispose is less critical now as ref.listen handles lifecycle,
  // but keeping it doesn't hurt if other manual subscriptions were added.
  @override
  void dispose() {
    log("[AddSectionViewModel] Disposing.");
    // _profileSubscription?.cancel(); // ref.listen handles this
    super.dispose();
  }
}

// Provider for the AddSectionViewModel
final addSectionViewModelProvider =
    StateNotifierProvider.autoDispose<AddSectionViewModel, AddSectionState>((ref) {
  return AddSectionViewModel(ref);
});
