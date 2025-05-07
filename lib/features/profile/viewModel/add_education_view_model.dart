import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_education_state.dart';
import 'dart:async';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';

class AddEducationViewModel extends StateNotifier<AddEducationFormState> {
  final ProfileService _profileService;
  final Ref _ref;

  final int maxDescriptionChars = 2000;
  final int maxActivitiesChars = 500;
  final int maxGradeChars = 50;
  final int maxDegreeChars = 50;
  final int maxFieldOfStudyChars = 100;
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
  String? _editingEducationId;
  bool get isEditMode => _editingEducationId != null;
  List<String>? _skills;
  List<Map<String, dynamic>> _mediaList = [];
  AddEducationViewModel(this._profileService, this._ref)
      
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
          mediaList: [],
          
        ))) {
    state = AddEducationIdle(_createFormData());
    _descriptionController.addListener(() => _updateFormDataState());
    _activitiesController.addListener(() => _updateFormDataState());
  }

   AddEducationFormData _createFormData() {
     return AddEducationFormData(
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
        skills: _skills,
        mediaList: List.unmodifiable(_mediaList),

      );
   }

  void _updateFormDataState() {
    if (!mounted) return;
    final currentState = state;
    if (currentState is AddEducationIdle || currentState is AddEducationFailure) {
      final currentFormData = _createFormData();
      if (currentState is AddEducationIdle) {
         state = AddEducationIdle(currentFormData);
      } else if (currentState is AddEducationFailure) {
         state = AddEducationFailure(currentFormData, currentState.message);
      }
    }
  }

  void initializeForEdit(EducationModel education) {
    log("Initializing Education ViewModel for Edit: ${education.id}");
    _editingEducationId = education.id;

    _schoolController.text = education.institution;
    _degreeController.text = education.degree;
    _fieldOfStudyController.text = education.fieldOfStudy;
    _gradeController.text = education.grade ?? '';
    _activitiesController.text = education.activitesAndSocials ?? '';
    _descriptionController.text = education.description ?? '';

    _selectedSchoolData = education.schoolData;
    _schoolController.text = _selectedSchoolData?['name'] ?? education.institution;
    _skills = education.skills != null ? List<String>.from(education.skills!) : null; 
    _mediaList = List<Map<String, dynamic>>.from(education.media ?? []); 

    _selectedStartDate = DateTime.tryParse(education.startDate);
    _startDateController.text = _selectedStartDate != null ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!) : '';

    _isEndDatePresent = (education.endDate == null || education.endDate!.isEmpty);
    if (_isEndDatePresent) {
      _selectedEndDate = null;
      _endDateController.text = 'Present';
    } else {
      _selectedEndDate = DateTime.tryParse(education.endDate!);
      _endDateController.text = _selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!) : '';
    }

     _updateFormDataState();
    log("Education ViewModel Initialized: ID=$_editingEducationId, School=${_schoolController.text}");
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
      _endDateController.text = _selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!) : '';
    }
    _updateFormDataState();
  }

  String? validateForm() {
    final schoolId = _selectedSchoolData?['_id'];
    final today = DateUtils.dateOnly(DateTime.now());
    if (_selectedSchoolData == null || schoolId == null || schoolId.trim().isEmpty) {
      return "School is required.";
    }
    if (_selectedStartDate!.isAfter(today)) {
         return "Start date cannot be in the future.";
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
    if (_gradeController.text.length > maxGradeChars) {
      return "Grade cannot exceed $maxGradeChars characters (currently ${_gradeController.text.length}).";
    }
    if (_fieldOfStudyController.text.length > maxFieldOfStudyChars) {
      return "Field of Study cannot exceed $maxFieldOfStudyChars characters (currently ${_fieldOfStudyController.text.length}).";
    }
    if (_degreeController.text.length > maxDegreeChars) {
      return "Degree cannot exceed $maxDegreeChars characters (currently ${_degreeController.text.length}).";
    }
    for (var mediaItem in _mediaList) {
       if (mediaItem['title'] == null || (mediaItem['title'] as String).trim().isEmpty) {
          return "Media title cannot be empty.";
       }
    }
    
    return null;
  }

  Future<void> saveEducation(List<String> currentSkills) async { 
    final currentFormData = _getFormDataFromState(state);
    if (currentFormData == null) {
       log("Cannot save, current form data state is null.");
       return;
    }

    final validationError = validateForm();
    if (validationError != null) {
      state = AddEducationFailure(currentFormData, validationError);
      return;
    }

    state = AddEducationLoading(currentFormData);

    final educationModel = EducationModel(
      id: _editingEducationId,
      schoolData: _selectedSchoolData,
      institution: _schoolController.text.trim(),
      degree: _degreeController.text.trim(),
      fieldOfStudy: _fieldOfStudyController.text.trim(),
      startDate: _selectedStartDate != null ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!) : '',
      endDate: _isEndDatePresent ? null : (_selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!) : null),
      grade: _gradeController.text.trim().isNotEmpty ? _gradeController.text.trim() : null,
      activitesAndSocials: _activitiesController.text.trim().isNotEmpty ? _activitiesController.text.trim() : null,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      skills: currentSkills.isNotEmpty ? List.from(currentSkills) : null, 

    );

    try {
      bool success;
      if (isEditMode) {
        log("Calling updateEducation for ID: $_editingEducationId");
        success = await _profileService.updateEducation(_editingEducationId!, educationModel);
      } else {
        log("Calling addEducation");
        success = await _profileService.addEducation(educationModel);
      }

      if (success && mounted) {
        unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile());
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
    log("Resetting form. Edit mode was: $isEditMode");
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
    _editingEducationId = null;
    _skills = null;
     if (mounted) {
       state = AddEducationIdle(_createFormData());
     }
    _mediaList=[];
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
  return AddEducationViewModel(profileService, ref);
});