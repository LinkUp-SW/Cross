import 'package:flutter/material.dart'; // Needed for TextEditingController

// Base state for the Add/Edit Education Form page
sealed class AddEducationFormState {
  const AddEducationFormState();
}

// State holding the current data entered in the form
class AddEducationFormData extends AddEducationFormState {
  final TextEditingController schoolController;
  final TextEditingController degreeController;
  final TextEditingController fieldOfStudyController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController gradeController;
  final TextEditingController activitiesController;
  final TextEditingController descriptionController;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final bool isEndDatePresent; // Manages the 'Present' checkbox

  const AddEducationFormData({
    required this.schoolController,
    required this.degreeController,
    required this.fieldOfStudyController,
    required this.startDateController,
    required this.endDateController,
    required this.gradeController,
    required this.activitiesController,
    required this.descriptionController,
    this.selectedStartDate,
    this.selectedEndDate,
    this.isEndDatePresent = false,
  });

  // copyWith method to easily create new states with updated data
  AddEducationFormData copyWith({
    TextEditingController? schoolController,
    TextEditingController? degreeController,
    TextEditingController? fieldOfStudyController,
    TextEditingController? startDateController,
    TextEditingController? endDateController,
    TextEditingController? gradeController,
    TextEditingController? activitiesController,
    TextEditingController? descriptionController,
    // Use Object() trick to allow explicitly setting dates to null
    Object? selectedStartDate = const Object(),
    Object? selectedEndDate = const Object(),
    bool? isEndDatePresent,
  }) {
    return AddEducationFormData(
      schoolController: schoolController ?? this.schoolController,
      degreeController: degreeController ?? this.degreeController,
      fieldOfStudyController: fieldOfStudyController ?? this.fieldOfStudyController,
      startDateController: startDateController ?? this.startDateController,
      endDateController: endDateController ?? this.endDateController,
      gradeController: gradeController ?? this.gradeController,
      activitiesController: activitiesController ?? this.activitiesController,
      descriptionController: descriptionController ?? this.descriptionController,
      selectedStartDate: selectedStartDate == const Object() ? this.selectedStartDate : selectedStartDate as DateTime?,
      selectedEndDate: selectedEndDate == const Object() ? this.selectedEndDate : selectedEndDate as DateTime?,
      isEndDatePresent: isEndDatePresent ?? this.isEndDatePresent,
    );
  }
}

// States representing the status of the save/API operation
sealed class AddEducationStatusState extends AddEducationFormState {
    const AddEducationStatusState();
}

// The form is ready for input or has returned from a loading/error state
class AddEducationIdle extends AddEducationStatusState {
  final AddEducationFormData formData; // Holds the current form data
  const AddEducationIdle(this.formData);
}

// Currently attempting to save the data via the service
class AddEducationLoading extends AddEducationStatusState {
    final AddEducationFormData formData; // Keep form data to display while loading
    const AddEducationLoading(this.formData);
}

// Data was successfully saved
class AddEducationSuccess extends AddEducationStatusState {
  const AddEducationSuccess();
}

// An error occurred during the save operation
class AddEducationFailure extends AddEducationStatusState {
  final AddEducationFormData formData; // Keep form data to allow user to retry
  final String message;
  const AddEducationFailure(this.formData, this.message);
}