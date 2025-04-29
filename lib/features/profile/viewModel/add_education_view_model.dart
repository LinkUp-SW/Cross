// lib/features/profile/viewModel/add_education_view_model.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_education_state.dart';

class AddEducationViewModel extends StateNotifier<AddEducationFormState> {
  final ProfileService _profileService;

  final int maxDescriptionChars = 2000;
  final int maxActivitiesChars = 500;

  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _activitiesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isEndDatePresent = false;
  Map<String, String>? _selectedSchoolData;

  AddEducationViewModel(this._profileService)
      : super(AddEducationIdle(AddEducationFormData(
          schoolController: TextEditingController(),
          degreeController: TextEditingController(),
          fieldOfStudyController: TextEditingController(),
          startDateController: TextEditingController(),
          endDateController: TextEditingController(),
          gradeController: TextEditingController(),
          activitiesController: TextEditingController(),
          descriptionController: TextEditingController(),
          isEndDatePresent: false,
        ))) {
     state = AddEducationIdle(AddEducationFormData(
        schoolController: _schoolController,
        degreeController: _degreeController,
        fieldOfStudyController: _fieldOfStudyController,
        startDateController: _startDateController,
        endDateController: _endDateController,
        gradeController: _gradeController,
        activitiesController: _activitiesController,
        descriptionController: _descriptionController,
        selectedStartDate: _selectedStartDate,
        selectedEndDate: _selectedEndDate,
        isEndDatePresent: _isEndDatePresent,
     ));

     _descriptionController.addListener(() => _updateFormDataState());
     _activitiesController.addListener(() => _updateFormDataState());

  }

  void _updateFormDataState() {
     if (state is AddEducationIdle || state is AddEducationFailure) {
        final currentFormData = (state is AddEducationIdle)
            ? (state as AddEducationIdle).formData
            : (state is AddEducationFailure)
              ? (state as AddEducationFailure).formData
              : AddEducationFormData(
                  schoolController: _schoolController,
                  degreeController: _degreeController,
                  fieldOfStudyController: _fieldOfStudyController,
                  startDateController: _startDateController,
                  endDateController: _endDateController,
                  gradeController: _gradeController,
                  activitiesController: _activitiesController,
                  descriptionController: _descriptionController,
                  selectedStartDate: _selectedStartDate,
                  selectedEndDate: _selectedEndDate,
                  isEndDatePresent: _isEndDatePresent,
                );

         state = AddEducationIdle(currentFormData.copyWith(
            selectedStartDate: _selectedStartDate,
            selectedEndDate: _selectedEndDate,
            isEndDatePresent: _isEndDatePresent,
             schoolController: _schoolController,
             degreeController: _degreeController,
             fieldOfStudyController: _fieldOfStudyController,
             startDateController: _startDateController,
             endDateController: _endDateController,
             gradeController: _gradeController,
             activitiesController: _activitiesController,
             descriptionController: _descriptionController,
         ));
     }
  }

  void setSelectedSchool(Map<String, dynamic> schoolData) {
    _selectedSchoolData = schoolData.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    _selectedSchoolData?.removeWhere((key, value) => value.isEmpty);

    _schoolController.text = _selectedSchoolData?['name'] ?? '';
    log("ViewModel: School selected - Data (String Map): $_selectedSchoolData");
    _updateFormDataState();
  }

  void setDate(DateTime date, bool isStartDate) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    if (isStartDate) {
      _selectedStartDate = date;
      _startDateController.text = formattedDate;
    } else {
       if (!_isEndDatePresent) {
         _selectedEndDate = date;
         _endDateController.text = formattedDate;
       }
    }
     _updateFormDataState();
  }

 void setIsEndDatePresent(bool value) {
    _isEndDatePresent = value;
    if (_isEndDatePresent) {
      _selectedEndDate = null;
      _endDateController.text = "Present";
    } else {
       if (_selectedEndDate != null) {
         _endDateController.text = DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
       } else {
          _endDateController.clear();
       }
    }
     _updateFormDataState();
  }

  String? validateForm() {
    final schoolId = _selectedSchoolData?['_id'];
    if (_selectedSchoolData == null || schoolId == null || schoolId.trim().isEmpty) {
       return "School is required.";
    }
   

    if (_degreeController.text.trim().isEmpty) return "Degree is required.";
    if (_fieldOfStudyController.text.trim().isEmpty) return "Field of Study is required.";
    if (_startDateController.text.isEmpty) return "Start date is required.";
    if (!_isEndDatePresent && _endDateController.text.isEmpty) return "End date is required (or check 'currently studying').";

    if (!_isEndDatePresent && _selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
        return "End date cannot be before start date.";
      }
    }

    if (_descriptionController.text.length > maxDescriptionChars) {
      return "Description cannot exceed $maxDescriptionChars characters (currently ${_descriptionController.text.length}).";
    }
    if (_activitiesController.text.length > maxActivitiesChars) {
       return "Activities cannot exceed $maxActivitiesChars characters (currently ${_activitiesController.text.length}).";
    }
    return null;
  }

  Future<void> saveEducation() async {
     final currentFormData = _getFormDataFromState(state);
     if (currentFormData == null) return;

    final validationError = validateForm();
    if (validationError != null) {
      state = AddEducationFailure(currentFormData, validationError);
      return;
    }

    state = AddEducationLoading(currentFormData);

    final educationModel = EducationModel(
      schoolData: _selectedSchoolData,
      institution: _schoolController.text.trim(),
      degree: _degreeController.text.trim(),
      fieldOfStudy: _fieldOfStudyController.text.trim(),
      startDate: _startDateController.text,
      endDate: _isEndDatePresent ? null : _endDateController.text,
      grade: _gradeController.text.trim().isNotEmpty ? _gradeController.text.trim() : null,
      activitesAndSocials: _activitiesController.text.trim().isNotEmpty ? _activitiesController.text.trim() : null,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
    );

    try {
      final success = await _profileService.addEducation(educationModel);
      if (success && mounted) {
        state = const AddEducationSuccess();
         resetForm();
      } else if (mounted) {
        state = AddEducationFailure(currentFormData, "Failed to save education. Server error.");
      }
    } catch (e) {
      if (mounted) {
        state = AddEducationFailure(currentFormData, "An error occurred: ${e.toString()}");
      }
    }
  }

   AddEducationFormData? _getFormDataFromState(AddEducationFormState currentState) {
     if (currentState is AddEducationIdle) return currentState.formData;
     if (currentState is AddEducationLoading) return currentState.formData;
     if (currentState is AddEducationFailure) return currentState.formData;
     return null;
   }

  void resetForm() {
    _schoolController.clear();
    _degreeController.clear();
    _fieldOfStudyController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _gradeController.clear();
    _activitiesController.clear();
    _descriptionController.clear();
    _selectedStartDate = null;
    _selectedEndDate = null;
    _isEndDatePresent = false;
    _selectedSchoolData = null;
     state = AddEducationIdle(AddEducationFormData(
          schoolController: _schoolController,
          degreeController: _degreeController,
          fieldOfStudyController: _fieldOfStudyController,
          startDateController: _startDateController,
          endDateController: _endDateController,
          gradeController: _gradeController,
          activitiesController: _activitiesController,
          descriptionController: _descriptionController,
          selectedStartDate: _selectedStartDate,
          selectedEndDate: _selectedEndDate,
          isEndDatePresent: _isEndDatePresent,
     ));
  }


  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _gradeController.dispose();
    _activitiesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

final addEducationViewModelProvider =
    StateNotifierProvider.autoDispose<AddEducationViewModel, AddEducationFormState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddEducationViewModel(profileService);
});