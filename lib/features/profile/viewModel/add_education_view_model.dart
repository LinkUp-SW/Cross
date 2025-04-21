import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_education_state.dart';

class AddEducationViewModel extends StateNotifier<AddEducationFormState> {
  final ProfileService _profileService;

  // --- Define Max Character Limits ---
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
         ));
     }
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
    if (_schoolController.text.isEmpty) return "School is required.";
    if (_degreeController.text.isEmpty) return "Degree is required.";
    if (_fieldOfStudyController.text.isEmpty) return "Field of Study is required.";
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
     final currentFormData = (state is AddEducationIdle)
        ? (state as AddEducationIdle).formData
        : (state is AddEducationFailure)
          ? (state as AddEducationFailure).formData
          : null;

     if (currentFormData == null) return;


    final validationError = validateForm();
    if (validationError != null) {
      state = AddEducationFailure(currentFormData, validationError);
      return;
    }

    state = AddEducationLoading(currentFormData);

    final educationModel = EducationModel(
      institution: _schoolController.text,
      degree: _degreeController.text,
      fieldOfStudy: _fieldOfStudyController.text,
      startDate: _startDateController.text,
      endDate: _isEndDatePresent ? null : _endDateController.text,
      grade: _gradeController.text.isNotEmpty ? _gradeController.text : null,
      activities: _activitiesController.text.isNotEmpty ? _activitiesController.text : null,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
    );

    try {
      final success = await _profileService.addEducation(educationModel);
      if (success) {
        state = const AddEducationSuccess();
         resetForm();
      } else {
        state = AddEducationFailure(currentFormData, "Failed to save education. Server returned false.");
      }
    } catch (e) {
      state = AddEducationFailure(currentFormData, "An error occurred: ${e.toString()}");
    }
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
    StateNotifierProvider<AddEducationViewModel, AddEducationFormState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddEducationViewModel(profileService);
});