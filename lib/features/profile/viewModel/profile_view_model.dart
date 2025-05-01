import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/features/profile/model/about_model.dart';

// Existing providers
final experienceDataProvider = StateProvider<List<PositionModel>?>((ref) => null);
final educationDataProvider = StateProvider<List<EducationModel>?>((ref) => null);
final aboutDataProvider = StateProvider<AboutModel?>((ref) => null);
// New provider for Resume URL
final resumeUrlProvider = StateProvider<String?>((ref) => null); // Holds the URL or null

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final Ref _ref;
  String? _currentUserId;

  ProfileViewModel(this._profileService, this._ref) : super(const ProfileInitial());

  Future<void> fetchUserProfile([String? userId]) async {
    final String idToFetch = userId ?? InternalEndPoints.userId;

    if (idToFetch.isEmpty) {
      state = const ProfileError("User ID not available. Please log in.");
      return;
    }
    if (state is ProfileLoading && _currentUserId == idToFetch) return;

    log("ViewModel fetching profile for ID: $idToFetch");
    state = const ProfileLoading();
    _currentUserId = idToFetch;

    // Clear previous data before fetching new data
    _ref.read(educationDataProvider.notifier).state = null;
    _ref.read(experienceDataProvider.notifier).state = null;
    _ref.read(aboutDataProvider.notifier).state = null;
    _ref.read(resumeUrlProvider.notifier).state = null; // Clear resume provider too


    try {
      // Fetch all data concurrently
      final userProfileFuture = _profileService.getUserProfile(idToFetch);
      final educationFuture = _profileService.getUserEducation(idToFetch);
      final experienceFuture = _profileService.getUserExperience(idToFetch);
      final aboutFuture = _profileService.getUserAboutAndSkills(idToFetch);
      final resumeUrlFuture = _profileService.getCurrentResumeUrl(idToFetch); // <-- Fetch resume URL

      // Wait for all futures to complete
      final results = await Future.wait([
        userProfileFuture,
        educationFuture,
        experienceFuture,
        aboutFuture,
        resumeUrlFuture // <-- Add future to wait list
      ]);

      // Cast results - handle potential type errors if needed
      // Check length before accessing indices
      if (results.length < 5) {
         throw Exception("One or more profile fetch operations failed to return.");
      }

      final userProfile = results[0] as UserProfile;
      final educationData = results[1] as List<EducationModel>;
      final experienceData = results[2] as List<PositionModel>;
      final aboutData = results[3] as AboutModel;
      final resumeUrl = results[4] as String?; // <-- Get resume URL result

      if (mounted) {
        // Update profile URL if available
        if (userProfile.profilePhotoUrl.isNotEmpty) {
          InternalEndPoints.profileUrl = userProfile.profilePhotoUrl;
        } else {
          InternalEndPoints.profileUrl = '';
        }

        // Update state providers
        _ref.read(educationDataProvider.notifier).state = educationData;
        _ref.read(experienceDataProvider.notifier).state = experienceData;
        _ref.read(aboutDataProvider.notifier).state = aboutData;
        _ref.read(resumeUrlProvider.notifier).state = resumeUrl; // <-- Update resume provider

        log("ProfileViewModel: Updated experienceDataProvider with ${experienceData.length} items.");
        log("ProfileViewModel: Updated educationDataProvider with ${educationData.length} items.");
        log("ProfileViewModel: Updated aboutDataProvider. About text length: ${aboutData.about.length}, Skills count: ${aboutData.skills.length}");
        log("ProfileViewModel: Updated resumeUrlProvider. URL: $resumeUrl");


        // Set final loaded state
        state = ProfileLoaded(userProfile);
      }
    } catch (e, s) { // Catch stacktrace for more details
       if (mounted) {
         log("ViewModel caught error during fetchUserProfile: $e", stackTrace: s); // Log stacktrace
         state = ProfileError('Failed to load profile: ${e.toString()}');
         // Clear providers on error
         _ref.read(educationDataProvider.notifier).state = null;
         _ref.read(experienceDataProvider.notifier).state = null;
         _ref.read(aboutDataProvider.notifier).state = null;
         _ref.read(resumeUrlProvider.notifier).state = null; // Clear resume provider on error
       }
    }
  }

  // updateProfilePhotoUrl and updateCoverPhotoUrl methods remain the same
  // ...
   void updateProfilePhotoUrl(String newUrl) {
     final ProfileState currentState = state;
     if (currentState is ProfileLoaded) {
        final UserProfile currentProfile = currentState.userProfile;
        final UserProfile updatedProfile = UserProfile(
           isMe: currentProfile.isMe,
           firstName: currentProfile.firstName,
           lastName: currentProfile.lastName,
           headline: currentProfile.headline,
           countryRegion: currentProfile.countryRegion,
           city: currentProfile.city,
           profilePhotoUrl: newUrl, // Update photo
           coverPhotoUrl: currentProfile.coverPhotoUrl,
           numberOfConnections: currentProfile.numberOfConnections,
           website: currentProfile.website,
        );
        final ProfileLoaded newState = ProfileLoaded(updatedProfile);
        state = newState;
        log("ProfileViewModel: Updated profilePhotoUrl in state.");
        InternalEndPoints.profileUrl = newUrl;
     } else {
        log("ProfileViewModel: Cannot update profile photo URL, state is not ProfileLoaded. Current state: $currentState");
     }
  }

  void updateCoverPhotoUrl(String newUrl) {
     final ProfileState currentState = state;
     if (currentState is ProfileLoaded) {
        final UserProfile currentProfile = currentState.userProfile;
        final UserProfile updatedProfile = UserProfile(
           isMe: currentProfile.isMe,
           firstName: currentProfile.firstName,
           lastName: currentProfile.lastName,
           headline: currentProfile.headline,
           countryRegion: currentProfile.countryRegion,
           city: currentProfile.city,
           profilePhotoUrl: currentProfile.profilePhotoUrl,
           coverPhotoUrl: newUrl, // Update cover
           numberOfConnections: currentProfile.numberOfConnections,
            website: currentProfile.website,
        );
        final ProfileLoaded newState = ProfileLoaded(updatedProfile);
        state = newState;
        log("ProfileViewModel: Updated coverPhotoUrl in state.");
     } else {
        log("ProfileViewModel: Cannot update cover photo URL, state is not ProfileLoaded. Current state: $currentState");
     }
  }
}


final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileViewModel(profileService,ref);
});