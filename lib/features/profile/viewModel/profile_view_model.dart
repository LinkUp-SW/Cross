import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/features/profile/model/about_model.dart';
import 'package:link_up/features/profile/model/skills_model.dart';

final experienceDataProvider =
    StateProvider<List<PositionModel>?>((ref) => null);
final educationDataProvider =
    StateProvider<List<EducationModel>?>((ref) => null);
final aboutDataProvider = StateProvider<AboutModel?>((ref) => null);
final resumeUrlProvider = StateProvider<String?>((ref) => null);
final licenseDataProvider = StateProvider<List<LicenseModel>?>((ref) => null);
final skillsDataProvider = StateProvider<List<SkillModel>?>((ref) => null);
final profileVisibilityProvider = StateProvider<bool>((ref) => false);

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final Ref _ref;
  String? _currentUserId;

  ProfileViewModel(this._profileService, this._ref)
      : super(const ProfileInitial());

  Future<void> fetchUserProfile([String? userId]) async {
    final String idToFetch = userId ?? InternalEndPoints.userId;

    if (idToFetch.isEmpty) {
      state = const ProfileError("User ID not available. Please log in.");
      return;
    }
    if (state is ProfileLoading && _currentUserId == idToFetch) return;

    log("[ProfileVM] Fetching profile for ID: $idToFetch");
    state = const ProfileLoading();
    _currentUserId = idToFetch;

    // Reset all providers
    _ref.read(educationDataProvider.notifier).state = null;
    _ref.read(experienceDataProvider.notifier).state = null;
    _ref.read(aboutDataProvider.notifier).state = null;
    _ref.read(resumeUrlProvider.notifier).state = null;
    _ref.read(licenseDataProvider.notifier).state = null;
    _ref.read(skillsDataProvider.notifier).state = null;

    try {
      // Fetch profile visibility as part of the initial data load
      bool isProfilePublic = false;
      try {
        isProfilePublic = await getProfilePrivacy();
        // Store the visibility value in the provider
        _ref.read(profileVisibilityProvider.notifier).state = isProfilePublic;
        log("[ProfileVM] Profile visibility set to: ${isProfilePublic ? 'public' : 'private'}");
      } catch (e) {
        log("[ProfileVM] Failed to fetch profile visibility: $e");
      }

      // Continue with other profile data fetching...
      final userProfileFuture = _profileService.getUserProfile(idToFetch);
      final educationFuture = _profileService.getUserEducation(idToFetch);
      final experienceFuture = _profileService.getUserExperience(idToFetch);
      final aboutFuture = _profileService.getUserAboutAndSkills(idToFetch);
      final resumeUrlFuture = _profileService.getCurrentResumeUrl(idToFetch);
      final licensesFuture = _profileService.getUserLicenses(idToFetch);
      final skillsFuture = _profileService.getUserSkills(idToFetch);
      final results = await Future.wait([
        userProfileFuture,
        educationFuture,
        experienceFuture,
        aboutFuture,
        resumeUrlFuture,
        licensesFuture,
        skillsFuture,
      ]);

      if (results.length < 7) {
        throw Exception(
            "One or more profile fetch operations failed to return.");
      }

      final userProfile = results[0] as UserProfile;
      final educationData = results[1] as List<EducationModel>;
      final experienceData = results[2] as List<PositionModel>;
      final aboutData = results[3] as AboutModel;
      final resumeUrl = results[4] as String?;
      final licenseData = results[5] as List<LicenseModel>;
      final skillsData = results[6] as List<SkillModel>;

      if (mounted) {
        if (userProfile.isMe && userProfile.profilePhotoUrl.isNotEmpty) {
          InternalEndPoints.profileUrl = userProfile.profilePhotoUrl;
        } else if (userProfile.isMe) {
          InternalEndPoints.profileUrl = '';
        }

        _ref.read(educationDataProvider.notifier).state = educationData;
        _ref.read(experienceDataProvider.notifier).state = experienceData;
        _ref.read(aboutDataProvider.notifier).state = aboutData;
        _ref.read(resumeUrlProvider.notifier).state = resumeUrl;
        _ref.read(licenseDataProvider.notifier).state = licenseData;
        _ref.read(skillsDataProvider.notifier).state = skillsData;

        log("[ProfileVM] Updated experienceDataProvider with ${experienceData.length} items.");
        log("[ProfileVM] Updated educationDataProvider with ${educationData.length} items.");
        log("[ProfileVM] Updated aboutDataProvider. About text length: ${aboutData.about.length}, Skills count: ${aboutData.skills.length}");
        log("[ProfileVM] Updated resumeUrlProvider. URL: $resumeUrl");
        log("[ProfileVM] Updated licenseDataProvider with ${licenseData.length} items.");
        log("[ProfileVM] Updated skillsDataProvider with ${skillsData.length} items.");

        // Update UserProfile with visibility setting
        final updatedProfile =
            userProfile.copyWith(isPublicProfile: isProfilePublic);
        state = ProfileLoaded(updatedProfile);
        log("[ProfileVM] Profile loaded successfully for ID: $idToFetch. isMe: ${userProfile.isMe}");
      }
    } catch (e, s) {
      if (mounted) {
        log("[ProfileVM] Error during fetchUserProfile for ID: $idToFetch - $e",
            stackTrace: s);
        state = ProfileError('Failed to load profile: ${e.toString()}');
        _ref.read(educationDataProvider.notifier).state = null;
        _ref.read(experienceDataProvider.notifier).state = null;
        _ref.read(aboutDataProvider.notifier).state = null;
        _ref.read(resumeUrlProvider.notifier).state = null;
        _ref.read(licenseDataProvider.notifier).state = null;
        _ref.read(skillsDataProvider.notifier).state = null;
      }
    }
  }

  void updateProfilePhotoUrl(String newUrl) {
    final ProfileState currentState = state;
    if (currentState is ProfileLoaded) {
      final UserProfile currentProfile = currentState.userProfile;
      final UserProfile updatedProfile =
          currentProfile.copyWith(profilePhotoUrl: newUrl);

      state = ProfileLoaded(updatedProfile);
      log("[ProfileVM] Updated profilePhotoUrl in state.");
      if (updatedProfile.isMe) {
        InternalEndPoints.profileUrl = newUrl;
      }
    } else {
      log("[ProfileVM] Cannot update profile photo URL, state is not ProfileLoaded. Current state: $currentState");
    }
  }

  void updateCoverPhotoUrl(String newUrl) {
    final ProfileState currentState = state;
    if (currentState is ProfileLoaded) {
      final UserProfile currentProfile = currentState.userProfile;
      final UserProfile updatedProfile =
          currentProfile.copyWith(coverPhotoUrl: newUrl);
      state = ProfileLoaded(updatedProfile);
      log("[ProfileVM] Updated coverPhotoUrl in state.");
    } else {
      log("[ProfileVM] Cannot update cover photo URL, state is not ProfileLoaded. Current state: $currentState");
    }
  }

  Future<void> sendConnectionRequest(
    String targetUserId, {
    Map<String, dynamic>? body,
  }) async {
    state = ProfileLoading();
    try {
      await _profileService.sendConnectionRequest(targetUserId, body: body);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error sending connection request to user with id: $targetUserId");
      state =
          ProfileError("Could not send connection request to this person :(");
    }
  }

  // Method to handle withdrawing a connection request
  Future<void> withdrawConnectionRequest(String targetUserId) async {
    state = ProfileLoading();
    try {
      await _profileService.withdrawInvitation(targetUserId);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error withdrawing user with id: $targetUserId");
      state = ProfileError(
          "Could not withdraw connection request with this person :(");
    }
  }

  Future<void> followUser(String targetUserId) async {
    state = ProfileLoading();
    try {
      await _profileService.follow(targetUserId);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error following user with id: $targetUserId");
      state = ProfileError("Could not unfollow this person :(");
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    state = ProfileLoading();
    try {
      await _profileService.unfollow(targetUserId);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error unfollowing user with id: $targetUserId");
      state = ProfileError("Could not unfollow this person :(");
    }
  }

  Future<void> acceptInvitation(String targetUserId) async {
    state = ProfileLoading();
    try {
      await _profileService.acceptInvitation(targetUserId);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error accepting invitation from user with id: $targetUserId");
      state = ProfileError("Could not accept invitation from this person :(");
    }
  }

  Future<void> ignoreInvitation(String targetUserId) async {
    state = ProfileLoading();
    try {
      await _profileService.ignoreInvitation(targetUserId);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error ignoring invitation from user with id: $targetUserId");
      state = ProfileError("Could not ignore invitation from this person :(");
    }
  }

  Future<void> removeConnection(String targetUserId) async {
    state = ProfileLoading();
    try {
      await _profileService.removeConnection(targetUserId);
      final otherUserProfile =
          await _profileService.getUserProfile(targetUserId);
      state = ProfileLoaded(otherUserProfile);
    } catch (error) {
      log("Error removing user with id: $targetUserId from connections");
      state = ProfileError("Could not remove this person from connections :(");
    }
  }

  Future<bool> getProfilePrivacy() async {
    try {
      final response = await _profileService.getProfileVisibility();
      final privacySetting = response['profileVisibility'];
      return (privacySetting != null || privacySetting == "")
          ? privacySetting == 'public'
              ? true
              : false
          : false;
    } catch (error) {
      log("Error returning profile visibility $error");
      rethrow;
    }
  }
}

// --- Provider Definition ---
final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  // You might need to watch other services here later (e.g., ConnectionService)
  return ProfileViewModel(profileService, ref);
});
