import 'package:flutter/material.dart'; 

sealed class AddEducationFormState {
  const AddEducationFormState();
}

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
  final bool isEndDatePresent; 
  final List<String>? skills; 
  final List<Map<String, dynamic>>? mediaList;



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
    this.skills,
    this.mediaList

  });

  AddEducationFormData copyWith({
    TextEditingController? schoolController,
    TextEditingController? degreeController,
    TextEditingController? fieldOfStudyController,
    TextEditingController? startDateController,
    TextEditingController? endDateController,
    TextEditingController? gradeController,
    TextEditingController? activitiesController,
    TextEditingController? descriptionController,
    Object? selectedStartDate = const Object(),
    Object? selectedEndDate = const Object(),
    bool? isEndDatePresent,
    List<String>? skills,
    List<Map<String, dynamic>>? mediaList,
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
      skills: skills ?? this.skills,
      mediaList: mediaList ?? this.mediaList,

    );
  }
}

sealed class AddEducationStatusState extends AddEducationFormState {
    const AddEducationStatusState();
}

class AddEducationIdle extends AddEducationStatusState {
  final AddEducationFormData formData; 
  const AddEducationIdle(this.formData);
}

class AddEducationLoading extends AddEducationStatusState {
    final AddEducationFormData formData; 
    const AddEducationLoading(this.formData);
}

class AddEducationSuccess extends AddEducationStatusState {
  const AddEducationSuccess();
}

class AddEducationFailure extends AddEducationStatusState {
  final AddEducationFormData formData;
  final String message;
  const AddEducationFailure(this.formData, this.message);
}