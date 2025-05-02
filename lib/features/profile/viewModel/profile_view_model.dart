import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/model/profile_model.dart'; // Ensure UserProfile is imported
import 'package:link_up/features/profile/model/about_model.dart';
import 'package:link_up/features/profile/model/skills_model.dart';

// --- Providers for section data (These seem fine) ---
final experienceDataProvider = StateProvider<List<PositionModel>?>((ref) => null);
final educationDataProvider = StateProvider<List<EducationModel>?>((ref) => null);
final aboutDataProvider = StateProvider<AboutModel?>((ref) => null);
final resumeUrlProvider = StateProvider<String?>((ref) => null);
final licenseDataProvider = StateProvider<List<LicenseModel>?>((ref) => null);
final skillsDataProvider = StateProvider<List<SkillModel>?>((ref) => null);

// --- ProfileViewModel ---
class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final Ref _ref;
  String? _currentUserId; // Tracks the ID being displayed

  ProfileViewModel(this._profileService, this._ref) : super(const ProfileInitial());

  /// Fetches the complete profile data for a given user ID.
  /// If no userId is provided, it defaults to the logged-in user's ID.
  Future<void> fetchUserProfile([String? userId]) async {
    // Determine the target user ID
    final String idToFetch = userId ?? InternalEndPoints.userId;

    // Basic checks
    if (idToFetch.isEmpty) {
      state = const ProfileError("User ID not available. Please log in.");
      return;
    }
    // Avoid redundant fetches if already loading the same profile
    if (state is ProfileLoading && _currentUserId == idToFetch) return;

    log("[ProfileVM] Fetching profile for ID: $idToFetch");
    state = const ProfileLoading();
    _currentUserId = idToFetch; // Store the ID we are fetching

    // Reset section data providers
    _ref.read(educationDataProvider.notifier).state = null;
    _ref.read(experienceDataProvider.notifier).state = null;
    _ref.read(aboutDataProvider.notifier).state = null;
    _ref.read(resumeUrlProvider.notifier).state = null;
    _ref.read(licenseDataProvider.notifier).state = null;
    _ref.read(skillsDataProvider.notifier).state = null;

    try {
      // Fetch all profile parts concurrently
      // IMPORTANT: Ensure _profileService.getUserProfile fetches the full UserProfile
      // including is_me and the other boolean flags.
      final userProfileFuture = _profileService.getUserProfile(idToFetch);
      final educationFuture = _profileService.getUserEducation(idToFetch);
      final experienceFuture = _profileService.getUserExperience(idToFetch);
      final aboutFuture = _profileService.getUserAboutAndSkills(idToFetch);
      final resumeUrlFuture = _profileService.getCurrentResumeUrl(idToFetch);
      final licensesFuture = _profileService.getUserLicenses(idToFetch);
      final skillsFuture = _profileService.getUserSkills(idToFetch);

      // Wait for all futures to complete
      final results = await Future.wait([
        userProfileFuture,
        educationFuture,
        experienceFuture,
        aboutFuture,
        resumeUrlFuture,
        licensesFuture,
        skillsFuture,
      ]);

      // Basic validation of results (adjust index if more futures are added)
      if (results.length < 7) {
         throw Exception("One or more profile fetch operations failed to return.");
      }

      // --- Extract results ---
      // UserProfile should now contain 'isMe' and other flags parsed by UserProfile.fromJson
      final userProfile = results[0] as UserProfile;
      final educationData = results[1] as List<EducationModel>;
      final experienceData = results[2] as List<PositionModel>;
      final aboutData = results[3] as AboutModel;
      final resumeUrl = results[4] as String?;
      final licenseData = results[5] as List<LicenseModel>;
      final skillsData = results[6] as List<SkillModel>;

      // Check if the notifier is still mounted before updating state
      if (mounted) {
        // Update global profile URL if it's the user's own profile (optional)
        if (userProfile.isMe && userProfile.profilePhotoUrl.isNotEmpty) {
          InternalEndPoints.profileUrl = userProfile.profilePhotoUrl;
        } else if (userProfile.isMe) {
          InternalEndPoints.profileUrl = ''; // Clear if user deletes photo
        }

        // Update section data providers
        _ref.read(educationDataProvider.notifier).state = educationData;
        _ref.read(experienceDataProvider.notifier).state = experienceData;
        _ref.read(aboutDataProvider.notifier).state = aboutData;
        _ref.read(resumeUrlProvider.notifier).state = resumeUrl;
        _ref.read(licenseDataProvider.notifier).state = licenseData;
        _ref.read(skillsDataProvider.notifier).state = skillsData;

        // Log updates
        log("[ProfileVM] Updated experienceDataProvider with ${experienceData.length} items.");
        log("[ProfileVM] Updated educationDataProvider with ${educationData.length} items.");
        log("[ProfileVM] Updated aboutDataProvider. About text length: ${aboutData.about.length}, Skills count: ${aboutData.skills.length}");
        log("[ProfileVM] Updated resumeUrlProvider. URL: $resumeUrl");
        log("[ProfileVM] Updated licenseDataProvider with ${licenseData.length} items.");
        log("[ProfileVM] Updated skillsDataProvider with ${skillsData.length} items.");

        // --- Set the main state to ProfileLoaded with the complete UserProfile ---
        // This userProfile object now contains the crucial `isMe` flag and others.
        state = ProfileLoaded(userProfile);
        log("[ProfileVM] Profile loaded successfully for ID: $idToFetch. isMe: ${userProfile.isMe}");

      }
    } catch (e, s) {
       // Handle errors
       if (mounted) {
         log("[ProfileVM] Error during fetchUserProfile for ID: $idToFetch - $e", stackTrace: s);
         state = ProfileError('Failed to load profile: ${e.toString()}');
         // Clear section data on error
         _ref.read(educationDataProvider.notifier).state = null;
         _ref.read(experienceDataProvider.notifier).state = null;
         _ref.read(aboutDataProvider.notifier).state = null;
         _ref.read(resumeUrlProvider.notifier).state = null;
         _ref.read(licenseDataProvider.notifier).state = null;
         _ref.read(skillsDataProvider.notifier).state = null;
       }
    }
  }

    // --- Methods to update profile/cover photo URLs (These seem fine) ---
    void updateProfilePhotoUrl(String newUrl) {
      final ProfileState currentState = state;
      if (currentState is ProfileLoaded) {
         final UserProfile currentProfile = currentState.userProfile;
         // Use copyWith for immutability
         final UserProfile updatedProfile = currentProfile.copyWith(profilePhotoUrl: newUrl);

         state = ProfileLoaded(updatedProfile);
         log("[ProfileVM] Updated profilePhotoUrl in state.");
         // Update global endpoint only if it's the user's own profile
         if(updatedProfile.isMe) {
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
         // Use copyWith for immutability
         final UserProfile updatedProfile = currentProfile.copyWith(coverPhotoUrl: newUrl);
         state = ProfileLoaded(updatedProfile);
         log("[ProfileVM] Updated coverPhotoUrl in state.");
      } else {
         log("[ProfileVM] Cannot update cover photo URL, state is not ProfileLoaded. Current state: $currentState");
      }
   }

   // --- Potential Future Methods (Placeholder) ---

   // Method to handle sending a connection request
   Future<void> sendConnectionRequest(String targetUserId) async {
     // TODO: Implement connection request logic
     // 1. Set state to indicate loading (e.g., ProfileUpdatingConnection)
     // 2. Call a service method (e.g., _connectionService.sendRequest(targetUserId))
     // 3. On success: Update the UserProfile in the state (e.g., set is_in_sent_connections = true)
     // 4. On failure: Revert state and show error
     log("[ProfileVM] TODO: Implement sendConnectionRequest for $targetUserId");
       final currentState = state;
       if (currentState is ProfileLoaded) {
          // Example optimistic update (update UI immediately)
          state = ProfileLoaded(currentState.userProfile.copyWith(isInSentConnections: true));
          // Then call service, revert on failure
       }
   }

    // Method to handle withdrawing a connection request
   Future<void> withdrawConnectionRequest(String targetUserId) async {
     // TODO: Implement withdraw logic (similar structure to send request)
     log("[ProfileVM] TODO: Implement withdrawConnectionRequest for $targetUserId");
      final currentState = state;
       if (currentState is ProfileLoaded) {
          state = ProfileLoaded(currentState.userProfile.copyWith(isInSentConnections: false));
       }
   }

   // Method to handle following a user
   Future<void> followUser(String targetUserId) async {
      // TODO: Implement follow logic
      log("[ProfileVM] TODO: Implement followUser for $targetUserId");
       final currentState = state;
       if (currentState is ProfileLoaded) {
          state = ProfileLoaded(currentState.userProfile.copyWith(isAlreadyFollowing: true));
       }
   }

   // Method to handle unfollowing a user
   Future<void> unfollowUser(String targetUserId) async {
      // TODO: Implement unfollow logic
      log("[ProfileVM] TODO: Implement unfollowUser for $targetUserId");
       final currentState = state;
       if (currentState is ProfileLoaded) {
          state = ProfileLoaded(currentState.userProfile.copyWith(isAlreadyFollowing: false));
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