import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_position_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'dart:async';

class AddPositionViewModel extends StateNotifier<AddPositionState> {
  final ProfileService _profileService;
  final Ref _ref;
  final int maxDescriptionChars = 2000;

  final _titleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedEmploymentType;
  String? _selectedLocationType;
  Map<String, dynamic>? _selectedOrganization;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isCurrentPosition = false;
  List<String>? _skills;

  AddPositionViewModel(this._profileService, this._ref)
      : super(AddPositionInitial(AddPositionFormData.initial())) {
    state = AddPositionInitial(AddPositionFormData(
      titleController: _titleController,
      companyNameController: _companyNameController,
      locationController: _locationController,
      descriptionController: _descriptionController,
      startDateController: _startDateController,
      endDateController: _endDateController,
      selectedEmploymentType: _selectedEmploymentType,
      selectedLocationType: _selectedLocationType,
      selectedOrganization: _selectedOrganization,
      selectedStartDate: _selectedStartDate,
      selectedEndDate: _selectedEndDate,
      isCurrentPosition: _isCurrentPosition,
      skills: _skills,
    ));
  }

  AddPositionFormData _getCurrentFormData() {
    final currentState = state;
    if (currentState is AddPositionInitial) return currentState.formData;
    if (currentState is AddPositionLoading) return currentState.formData;
    if (currentState is AddPositionFailure) return currentState.formData;
    return AddPositionFormData.initial();
  }

  void _updateStateWithFormData(AddPositionFormData updatedData) {
    final currentState = state;
    if (currentState is AddPositionInitial || currentState is AddPositionFailure) {
      state = AddPositionInitial(updatedData);
    } else if (currentState is AddPositionLoading) {
      state = AddPositionLoading(updatedData);
    }
  }

  void setEmploymentType(String? type) {
    _selectedEmploymentType = type;
    _updateStateWithFormData(_getCurrentFormData().copyWith(selectedEmploymentType: type));
  }

  void setLocationType(String? type) {
    _selectedLocationType = type;
    _updateStateWithFormData(_getCurrentFormData().copyWith(selectedLocationType: type));
  }

  void setOrganization(Map<String, dynamic>? organization) {
    _selectedOrganization = organization;
    _companyNameController.text = organization?['name'] ?? '';
    _updateStateWithFormData(_getCurrentFormData().copyWith(selectedOrganization: organization));
  }

  void setDate(DateTime date, bool isStartDate) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    if (isStartDate) {
      _selectedStartDate = date;
      _startDateController.text = formattedDate;
    } else {
      if (!_isCurrentPosition) {
        _selectedEndDate = date;
        _endDateController.text = formattedDate;
      }
    }
    _updateStateWithFormData(_getCurrentFormData().copyWith(
      selectedStartDate: _selectedStartDate,
      selectedEndDate: _selectedEndDate,
    ));
  }

  void setIsCurrentPosition(bool value) {
    _isCurrentPosition = value;
    if (_isCurrentPosition) {
      _selectedEndDate = null;
      _endDateController.text = "Present";
    } else {
      if (_selectedEndDate != null) {
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
      } else {
        _endDateController.clear();
      }
    }
    _updateStateWithFormData(_getCurrentFormData().copyWith(
      isCurrentPosition: _isCurrentPosition,
      selectedEndDate: _selectedEndDate,
    ));
  }

  String? validateForm() {
    final formData = _getCurrentFormData();
    if (formData.titleController.text.trim().isEmpty) return "Title is required.";
    if (formData.companyNameController.text.trim().isEmpty || _selectedOrganization == null) return "Company/Organization is required.";
    if (formData.startDateController.text.isEmpty) return "Start date is required.";
    if (!formData.isCurrentPosition && formData.endDateController.text.isEmpty) return "End date is required (or check 'I am currently working here').";

    if (!formData.isCurrentPosition && _selectedStartDate != null && _selectedEndDate != null) {
      if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
        return "End date cannot be before start date.";
      }
    }

    if (formData.descriptionController.text.length > maxDescriptionChars) {
      return "Description cannot exceed $maxDescriptionChars characters (currently ${formData.descriptionController.text.length}).";
    }

    return null;
  }

  Future<void> savePosition() async {
    final currentFormData = _getCurrentFormData();
    final validationError = validateForm();

    if (validationError != null) {
      state = AddPositionFailure(currentFormData, validationError);
      return;
    }

    state = AddPositionLoading(currentFormData);

    final positionModel = PositionModel(
      title: currentFormData.titleController.text.trim(),
      employeeType: currentFormData.selectedEmploymentType ?? '',
      organizationId: currentFormData.selectedOrganization?['_id'] as String?,
      companyName: currentFormData.companyNameController.text.trim(),
      isCurrent: currentFormData.isCurrentPosition,
      startDate: currentFormData.startDateController.text,
      endDate: currentFormData.isCurrentPosition ? null : currentFormData.endDateController.text,
      description: currentFormData.descriptionController.text.isNotEmpty
          ? currentFormData.descriptionController.text.trim()
          : null,
      location: currentFormData.locationController.text.isNotEmpty
          ? currentFormData.locationController.text.trim()
          : null,
      locationType: currentFormData.selectedLocationType,
    );

    try {
      final success = await _profileService.addPosition(positionModel);

      if (success && mounted) {
        unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile());
        state = const AddPositionSuccess();
        resetForm(); 
      } else if (mounted) {
        state = AddPositionFailure(currentFormData, "Failed to save position. Server error.");
      }
    } catch (e) {
      state = AddPositionFailure(currentFormData, "An error occurred: ${e.toString()}");
    }
  }

  void resetForm() {
    _titleController.clear();
    _companyNameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();

    _selectedEmploymentType = null;
    _selectedLocationType = null;
    _selectedOrganization = null;
    _selectedStartDate = null;
    _selectedEndDate = null;
    _isCurrentPosition = false;
    _skills = null;

    state = AddPositionInitial(AddPositionFormData(
      titleController: _titleController,
      companyNameController: _companyNameController,
      locationController: _locationController,
      descriptionController: _descriptionController,
      startDateController: _startDateController,
      endDateController: _endDateController,
      selectedEmploymentType: _selectedEmploymentType,
      selectedLocationType: _selectedLocationType,
      selectedOrganization: _selectedOrganization,
      selectedStartDate: _selectedStartDate,
      selectedEndDate: _selectedEndDate,
      isCurrentPosition: _isCurrentPosition,
      skills: _skills,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}

final addPositionViewModelProvider =
    StateNotifierProvider.autoDispose<AddPositionViewModel, AddPositionState>((ref) { 
  final profileService = ref.watch(profileServiceProvider);
  return AddPositionViewModel(profileService, ref); 
});