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

final experienceDataProvider = StateProvider<List<PositionModel>?>((ref) => null);
final educationDataProvider = StateProvider<List<EducationModel>?>((ref) => null);
final aboutDataProvider = StateProvider<AboutModel?>((ref) => null);
final resumeUrlProvider = StateProvider<String?>((ref) => null);
final licenseDataProvider = StateProvider<List<LicenseModel>?>((ref) => null); 

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

    _ref.read(educationDataProvider.notifier).state = null;
    _ref.read(experienceDataProvider.notifier).state = null;
    _ref.read(aboutDataProvider.notifier).state = null;
    _ref.read(resumeUrlProvider.notifier).state = null;
    _ref.read(licenseDataProvider.notifier).state = null; 

    try {
      final userProfileFuture = _profileService.getUserProfile(idToFetch);
      final educationFuture = _profileService.getUserEducation(idToFetch);
      final experienceFuture = _profileService.getUserExperience(idToFetch);
      final aboutFuture = _profileService.getUserAboutAndSkills(idToFetch);
      final resumeUrlFuture = _profileService.getCurrentResumeUrl(idToFetch);
      final licensesFuture = _profileService.getUserLicenses(idToFetch); 

      final results = await Future.wait([
        userProfileFuture,
        educationFuture,
        experienceFuture,
        aboutFuture,
        resumeUrlFuture,
        licensesFuture 
      ]);

      if (results.length < 6) { 
         throw Exception("One or more profile fetch operations failed to return.");
      }

      final userProfile = results[0] as UserProfile;
      final educationData = results[1] as List<EducationModel>;
      final experienceData = results[2] as List<PositionModel>;
      final aboutData = results[3] as AboutModel;
      final resumeUrl = results[4] as String?;
      final licenseData = results[5] as List<LicenseModel>; 

      if (mounted) {
        if (userProfile.profilePhotoUrl.isNotEmpty) {
          InternalEndPoints.profileUrl = userProfile.profilePhotoUrl;
        } else {
          InternalEndPoints.profileUrl = '';
        }

        _ref.read(educationDataProvider.notifier).state = educationData;
        _ref.read(experienceDataProvider.notifier).state = experienceData;
        _ref.read(aboutDataProvider.notifier).state = aboutData;
        _ref.read(resumeUrlProvider.notifier).state = resumeUrl;
        _ref.read(licenseDataProvider.notifier).state = licenseData; 

        log("ProfileViewModel: Updated experienceDataProvider with ${experienceData.length} items.");
        log("ProfileViewModel: Updated educationDataProvider with ${educationData.length} items.");
        log("ProfileViewModel: Updated aboutDataProvider. About text length: ${aboutData.about.length}, Skills count: ${aboutData.skills.length}");
        log("ProfileViewModel: Updated resumeUrlProvider. URL: $resumeUrl");
        log("ProfileViewModel: Updated licenseDataProvider with ${licenseData.length} items.");  


        state = ProfileLoaded(userProfile);
      }
    } catch (e, s) { 
       if (mounted) {
         log("ViewModel caught error during fetchUserProfile: $e", stackTrace: s); 
         state = ProfileError('Failed to load profile: ${e.toString()}');
         _ref.read(educationDataProvider.notifier).state = null;
         _ref.read(experienceDataProvider.notifier).state = null;
         _ref.read(aboutDataProvider.notifier).state = null;
         _ref.read(resumeUrlProvider.notifier).state = null;
         _ref.read(licenseDataProvider.notifier).state = null; 
       }
    }
  }

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
            profilePhotoUrl: newUrl, 
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
            coverPhotoUrl: newUrl, 
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