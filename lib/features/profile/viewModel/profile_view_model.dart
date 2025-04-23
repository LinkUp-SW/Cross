import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/model/profile_model.dart';

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
        // Handle empty profilePhotoUrl explicitly
        if (userProfile.profilePhotoUrl.isNotEmpty) {
          InternalEndPoints.profileUrl = userProfile.profilePhotoUrl;
           log("ProfileViewModel: Updated InternalEndPoints.profileUrl with fetched URL.");
        } else {
          // If fetched URL is empty, set the static variable to empty
          InternalEndPoints.profileUrl = '';
          log("ProfileViewModel: Fetched profilePhotoUrl is empty, setting InternalEndPoints.profileUrl to empty.");
        }
        state = ProfileLoaded(userProfile);
      }
    } catch (e) {
       if (mounted) {
         log("ViewModel caught error: ${e.toString()}");
         state = ProfileError('Failed to load profile: ${e.toString()}');
       }
    }
  }

  void updateProfilePhotoUrl(String newUrl) {
     if (state is ProfileLoaded) {
        final currentProfile = (state as ProfileLoaded).userProfile;
        final updatedProfile = UserProfile(
           isMe: currentProfile.isMe,
           firstName: currentProfile.firstName,
           lastName: currentProfile.lastName,
           headline: currentProfile.headline,
           countryRegion: currentProfile.countryRegion,
           city: currentProfile.city,
           experience: currentProfile.experience,
           education: currentProfile.education,
           profilePhotoUrl: newUrl,
           coverPhotoUrl: currentProfile.coverPhotoUrl,
           numberOfConnections: currentProfile.numberOfConnections,
        );
        InternalEndPoints.profileUrl = newUrl;
        state = ProfileLoaded(updatedProfile);
        log("ProfileViewModel: Updated profilePhotoUrl in state and InternalEndPoints.");
     } else {
        log("ProfileViewModel: Cannot update photo URL, state is not ProfileLoaded.");
     }
  }
}

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileViewModel(profileService);
});