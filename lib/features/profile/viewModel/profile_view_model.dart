import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/core/constants/endpoints.dart'; 
import 'dart:developer'; // For log()

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  String? _currentUserId;

  ProfileViewModel(this._profileService) : super(const ProfileInitial());

  Future<void> fetchUserProfile([String? userId]) async {
    final String idToFetch = userId ?? InternalEndPoints.userId;

    if (idToFetch.isEmpty) {
      log("User ID is empty, cannot fetch profile.");
      state = const ProfileError("User ID not available. Please log in.");
      return;
    }
    if (state is ProfileLoading && _currentUserId == idToFetch) return;

    log("ViewModel fetching profile for ID: $idToFetch");
    state = const ProfileLoading();
    _currentUserId = idToFetch;

    try {
      final userProfile = await _profileService.getUserProfile(idToFetch);
      if (mounted) {
        state = ProfileLoaded(userProfile);
      }
    } catch (e) {
       if (mounted) {
         log("ViewModel caught error: ${e.toString()}");
         state = ProfileError('Failed to load profile: ${e.toString()}');
       }
    }
  }
}

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileViewModel(profileService);
});