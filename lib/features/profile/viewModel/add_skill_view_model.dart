import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/skills_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'dart:async';





class AddSkillViewModel extends StateNotifier<AddSkillState> {
  final ProfileService _profileService;
  final Ref _ref;

  final TextEditingController skillNameController = TextEditingController();

  AddSkillViewModel(this._profileService, this._ref) : super(const AddSkillInitial()) {
    loadLinkableItems();

    skillNameController.addListener(() {
      final currentState = state;
      if (currentState is AddSkillDataLoaded) {
        state = currentState.copyWith(currentSkillName: skillNameController.text);
      } else if (currentState is AddSkillError && currentState.previousData != null) {
         state = currentState.previousData!.copyWith(currentSkillName: skillNameController.text);
      }
    });
  }

  Future<void> loadLinkableItems() async {
    if (!mounted) return;
    log("[AddSkillVM] Loading linkable items...");
    state = const AddSkillLoadingItems();
    try {
      final sections = await _profileService.getUserSections();
      if (mounted) {
        skillNameController.clear(); 
        state = AddSkillDataLoaded(
          availableExperiences: sections['experience'] ?? [],
          availableEducations: sections['education'] ?? [],
          availableLicenses: sections['license'] ?? [],
        );
        log("[AddSkillVM] Linkable items loaded. Exp: ${sections['experience']?.length}, Edu: ${sections['education']?.length}, Lic: ${sections['license']?.length}");
      }
    } catch (e) {
      log("[AddSkillVM] Error loading linkable items: $e");
      if (mounted) {
        state = AddSkillError("Failed to load items to link: ${e.toString()}");
      }
    }
  }

  void toggleLink(String id, String type) {
    final currentState = state;
    if (currentState is! AddSkillDataLoaded) return;

    Set<String> updatedExperienceIds = Set.from(currentState.selectedExperienceIds);
    Set<String> updatedEducationIds = Set.from(currentState.selectedEducationIds);
    Set<String> updatedLicenseIds = Set.from(currentState.selectedLicenseIds);

    bool changed = false;
    switch (type) {
      case 'experience':
        if (updatedExperienceIds.contains(id)) {
          updatedExperienceIds.remove(id);
        } else {
          updatedExperienceIds.add(id);
        }
        changed = true;
        break;
      case 'education':
        if (updatedEducationIds.contains(id)) {
          updatedEducationIds.remove(id);
        } else {
          updatedEducationIds.add(id);
        }
        changed = true;
        break;
      case 'license':
        if (updatedLicenseIds.contains(id)) {
          updatedLicenseIds.remove(id);
        } else {
          updatedLicenseIds.add(id);
        }
        changed = true;
        break;
    }

    if (changed) {
      state = currentState.copyWith(
        selectedExperienceIds: updatedExperienceIds,
        selectedEducationIds: updatedEducationIds,
        selectedLicenseIds: updatedLicenseIds,
      );
      log("[AddSkillVM] Toggled link for $type ID: $id. New selections - Exp: ${updatedExperienceIds.length}, Edu: ${updatedEducationIds.length}, Lic: ${updatedLicenseIds.length}");
    }
  }

  String? _validateSave() {
    final currentState = state;
    if (currentState is! AddSkillDataLoaded) {
      return "Data not loaded yet.";
    }
    if (currentState.currentSkillName.trim().isEmpty) {
      return "Skill name is required.";
    }
    
    return null;
  }

  Future<void> saveSkill() async {
    final currentState = state;
    if (currentState is! AddSkillDataLoaded) return;

    final validationError = _validateSave();
    if (validationError != null) {
      state = AddSkillError(validationError, previousData: currentState);
       await Future.delayed(const Duration(milliseconds: 100)); 
       if (mounted && state is AddSkillError) {
          state = currentState; 
       }
      return;
    }

    state = AddSkillSaving(previousData: currentState);
    log("[AddSkillVM] Saving skill...");

    final skillToSave = SkillModel(
      name: currentState.currentSkillName.trim(),
      experiences: currentState.selectedExperienceIds.toList(),
      educations: currentState.selectedEducationIds.toList(),
      licenses: currentState.selectedLicenseIds.toList(),
    );

    try {
      final success = await _profileService.addSkill(skillToSave);
      if (success && mounted) {
        log("[AddSkillVM] Skill saved successfully.");
        state = const AddSkillSuccess();
        unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile());
      } else if (mounted) {
        log("[AddSkillVM] Save failed (service returned false or non-2xx status).");
        state = AddSkillError("Failed to save skill. Please try again.", previousData: currentState);
      }
    } catch (e) {
      log("[AddSkillVM] Error saving skill: $e");
      if (mounted) {
        state = AddSkillError("An error occurred: ${e.toString()}", previousData: currentState);
      }
    }
  }

  @override
  void dispose() {
    log("[AddSkillVM] Disposing.");
    skillNameController.dispose();
    super.dispose();
  }
}

// Provider definition
final addSkillViewModelProvider =
    StateNotifierProvider.autoDispose<AddSkillViewModel, AddSkillState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddSkillViewModel(profileService, ref);
});