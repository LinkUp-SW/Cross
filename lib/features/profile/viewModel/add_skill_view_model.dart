import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/skills_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';



class AddSkillViewModel extends StateNotifier<AddSkillState> {
  final ProfileService _profileService;
  final Ref _ref;

  final TextEditingController skillNameController = TextEditingController();
  String? _editingSkillId;
  SkillModel? _initialSkillDataForEdit; 
  bool get isEditMode => _editingSkillId != null;

    AddSkillViewModel(this._profileService, this._ref) : super(const AddSkillInitial()) {
   
    skillNameController.addListener(() {
      final currentState = state;
      if (currentState is AddSkillDataLoaded) {
         if (currentState.currentSkillName != skillNameController.text) {
            state = currentState.copyWith(currentSkillName: skillNameController.text);
         }
      } else if (currentState is AddSkillError && currentState.previousData != null) {
          if (currentState.previousData!.currentSkillName != skillNameController.text) {
             state = currentState.previousData!.copyWith(currentSkillName: skillNameController.text);
          }
      }
    });
  }


  void initializeForEdit(SkillModel skill) {
    log("Initializing Skill ViewModel for Edit: ${skill.id}");
    _initialSkillDataForEdit = skill; 
    _editingSkillId = skill.id;
    loadLinkableItems();
  }

  Future<void> loadLinkableItems() async {

    if (!mounted) return;
    log("[AddSkillVM] Loading linkable items... EditMode: $isEditMode");
    state = const AddSkillLoadingItems();
    try {
      final sections = await _profileService.getUserSections();
      if (mounted) {
        Set<String> initialExpIds = {};
        Set<String> initialEduIds = {};
        Set<String> initialLicIds = {};
        String initialSkillName = '';

        if (_initialSkillDataForEdit != null) {
           log("Applying initial edit data: ${_initialSkillDataForEdit!.name}");
           initialSkillName = _initialSkillDataForEdit!.name;
           initialExpIds = _initialSkillDataForEdit!.experiences?.toSet() ?? {};
           initialEduIds = _initialSkillDataForEdit!.educations?.toSet() ?? {};
           initialLicIds = _initialSkillDataForEdit!.licenses?.toSet() ?? {};
           skillNameController.text = initialSkillName; 
        } else {
           skillNameController.clear();
        }

        state = AddSkillDataLoaded(
          currentSkillName: initialSkillName, 
          availableExperiences: sections['experience'] ?? [],
          availableEducations: sections['education'] ?? [],
          availableLicenses: sections['license'] ?? [],
          selectedExperienceIds: initialExpIds,
          selectedEducationIds: initialEduIds,
          selectedLicenseIds: initialLicIds,
        );
        log("[AddSkillVM] Linkable items loaded. Initial selections - Exp: ${initialExpIds.length}, Edu: ${initialEduIds.length}, Lic: ${initialLicIds.length}");
        _initialSkillDataForEdit = null;
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
    AddSkillDataLoaded? dataToSave;
    if (currentState is AddSkillDataLoaded) {
       dataToSave = currentState;
    } else if (currentState is AddSkillError && currentState.previousData != null) {
       dataToSave = currentState.previousData!.copyWith(currentSkillName: skillNameController.text);
       log("Retrying save after error state.");
    }

    if (dataToSave == null) {
        log("Cannot save, state is not AddSkillDataLoaded or AddSkillError with previousData.");
        return; 
    }


    final validationError = _validateSave();  
    if (validationError != null) {
      state = AddSkillError(validationError, previousData: dataToSave);
       await Future.delayed(const Duration(milliseconds: 100));
       if (mounted && state is AddSkillError) {
          state = dataToSave;
       }
      return;
    }

    state = AddSkillSaving(previousData: dataToSave);
    log("[AddSkillVM] Saving skill... EditMode: $isEditMode");

    final skillToSave = SkillModel(
      id: _editingSkillId, 
      name: skillNameController.text.trim(), 
      experiences: dataToSave.selectedExperienceIds.toList(),
      educations: dataToSave.selectedEducationIds.toList(),
      licenses: dataToSave.selectedLicenseIds.toList(),
    );

    try {
      bool success;
      if (isEditMode) {
        log("Calling updateSkill for ID: $_editingSkillId");
        success = await _profileService.updateSkill(_editingSkillId!, skillToSave);
      } else {
        log("Calling addSkill");
        success = await _profileService.addSkill(skillToSave);
      }

      if (success && mounted) {
        log("[AddSkillVM] Skill ${isEditMode ? 'updated' : 'added'} successfully.");
        unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile());
        state = const AddSkillSuccess();
        resetForm(); 
      } else if (mounted) {
        log("[AddSkillVM] Save failed (service returned false or non-2xx status).");
        state = AddSkillError("Failed to save skill. Please try again.", previousData: dataToSave);
      }
    } catch (e) {
      log("[AddSkillVM] Error saving skill: $e");
      if (mounted) {
        state = AddSkillError("An error occurred: ${e.toString()}", previousData: dataToSave);
      }
    }
  }

   void resetForm() {
     log("Resetting AddSkillViewModel. Edit mode was: $isEditMode");
     skillNameController.clear();
     _editingSkillId = null;
     _initialSkillDataForEdit = null;

     if (mounted) {

         final currentState = state;
         if (currentState is AddSkillDataLoaded) {
             state = currentState.copyWith(
                currentSkillName: '',
                selectedExperienceIds: {},
                selectedEducationIds: {},
                selectedLicenseIds: {},
             );
         } else {
             loadLinkableItems();
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

final addSkillViewModelProvider =
    StateNotifierProvider.autoDispose<AddSkillViewModel, AddSkillState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddSkillViewModel(profileService, ref);
});