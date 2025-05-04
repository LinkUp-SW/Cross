// profile/viewModel/add_section_view_model.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_section_state.dart';
import 'package:link_up/features/profile/model/about_model.dart';
import 'package:link_up/features/profile/model/license_model.dart'; 
import 'package:link_up/features/profile/model/skills_model.dart';

class AddSectionViewModel extends StateNotifier<AddSectionState> {
  final Ref _ref;
  final ProfileService _profileService;
  final String _userId = InternalEndPoints.userId;

  AddSectionViewModel(this._ref, this._profileService) : super(const AddSectionState()) {
    refreshStatus();
  }

  Future<void> refreshStatus() async {
     if (!mounted) return;
     if (_userId.isEmpty) {
       
       state = state.copyWith(isLoading: false, error: "User not logged in.", hasAboutInfo: false, hasResume: false, hasLicenses: false);
       return;
     }

     log("[AddSectionViewModel] Refreshing profile status for user ID: $_userId");
     state = state.copyWith(isLoading: true, clearError: true);

     try {
       final aboutFuture = _profileService.getUserAboutAndSkills(_userId);
       final resumeUrlFuture = _profileService.getCurrentResumeUrl(_userId);
       final licensesFuture = _profileService.getUserLicenses(_userId);
       final skillsFuture = _profileService.getUserSkills(_userId);


       final List<Object?> results = await Future.wait([
         aboutFuture,
         resumeUrlFuture,
         licensesFuture ,
         skillsFuture
        ]);

        if (results.length < 4) {
           throw Exception("One or more status fetch operations failed.");
        }
       final AboutModel? aboutData = results[0] is AboutModel ? results[0] as AboutModel : null;
       final String? resumeUrl = results[1] is String ? results[1] as String : null;
       final List<LicenseModel>? licenses = results[2] is List<LicenseModel> ? results[2] as List<LicenseModel> : null;
      final List<SkillModel>? skills = results[3] is List<SkillModel> ? results[3] as List<SkillModel> : null;  


       if (mounted) {

          final bool aboutExists = aboutData?.about.isNotEmpty ?? false;
          final bool resumeExists = resumeUrl != null && resumeUrl.isNotEmpty;
          final bool licensesExist = licenses != null && licenses.isNotEmpty; 
          final bool hasSkills = skills != null && skills.isNotEmpty; 

          log("[AddSectionViewModel] Status Fetched. About: $aboutExists, Resume: $resumeExists, Licenses: $licensesExist" 
              ", Skills: $hasSkills");

          state = state.copyWith(
             isLoading: false,
             hasAboutInfo: aboutExists,
             hasResume: resumeExists,
             hasLicenses: licensesExist,
             hasSkills: hasSkills, 
             clearError: true, 
          );
          log("[AddSectionViewModel] Updated state: isLoading=${state.isLoading}, hasAboutInfo=${state.hasAboutInfo}, hasResume=${state.hasResume}, hasLicenses=${state.hasLicenses} , hasSkills=${state.hasSkills}");
       }
     } catch (e) {
       log("[AddSectionViewModel] Error refreshing profile status: $e");
       if (mounted) {
     
         state = state.copyWith(isLoading: false, error: "Failed to check profile sections: ${e.toString()}", hasAboutInfo: false, hasResume: false, hasLicenses: false);
       }
     }
  }

  @override
  void dispose() {
    log("[AddSectionViewModel] Disposing.");
    super.dispose();
  }
}

final addSectionViewModelProvider =
    StateNotifierProvider.autoDispose<AddSectionViewModel, AddSectionState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddSectionViewModel(ref, profileService);
});