import 'package:flutter/material.dart';
import 'package:link_up/features/profile/model/position_model.dart';

@immutable
sealed class AddPositionState {
  const AddPositionState();
}

class AddPositionFormData extends AddPositionState {
  final TextEditingController titleController;
  final TextEditingController companyNameController; 
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;

  final String? selectedEmploymentType;
  final String? selectedLocationType;
  final Map<String, dynamic>? selectedOrganization; 
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final bool isCurrentPosition;
  final List<String>? skills; 

  const AddPositionFormData({
    required this.titleController,
    required this.companyNameController,
    required this.locationController,
    required this.descriptionController,
    required this.startDateController,
    required this.endDateController,
    this.selectedEmploymentType,
    this.selectedLocationType,
    this.selectedOrganization,
    this.selectedStartDate,
    this.selectedEndDate,
    this.isCurrentPosition = false,
    this.skills,
  });

  factory AddPositionFormData.initial() {
    return AddPositionFormData(
      titleController: TextEditingController(),
      companyNameController: TextEditingController(),
      locationController: TextEditingController(),
      descriptionController: TextEditingController(),
      startDateController: TextEditingController(),
      endDateController: TextEditingController(),
    );
  }


  AddPositionFormData copyWith({
    TextEditingController? titleController,
    TextEditingController? companyNameController,
    TextEditingController? locationController,
    TextEditingController? descriptionController,
    TextEditingController? startDateController,
    TextEditingController? endDateController,
    String? selectedEmploymentType,
    String? selectedLocationType,
    Object? selectedOrganization = const Object(),
    Object? selectedStartDate = const Object(),
    Object? selectedEndDate = const Object(),
    bool? isCurrentPosition,
    List<String>? skills,
  }) {
    return AddPositionFormData(
      titleController: titleController ?? this.titleController,
      companyNameController: companyNameController ?? this.companyNameController,
      locationController: locationController ?? this.locationController,
      descriptionController: descriptionController ?? this.descriptionController,
      startDateController: startDateController ?? this.startDateController,
      endDateController: endDateController ?? this.endDateController,
      selectedEmploymentType: selectedEmploymentType ?? this.selectedEmploymentType,
      selectedLocationType: selectedLocationType ?? this.selectedLocationType,
      selectedOrganization: selectedOrganization == const Object() ? this.selectedOrganization : selectedOrganization as Map<String, dynamic>?,
      selectedStartDate: selectedStartDate == const Object() ? this.selectedStartDate : selectedStartDate as DateTime?,
      selectedEndDate: selectedEndDate == const Object() ? this.selectedEndDate : selectedEndDate as DateTime?,
      isCurrentPosition: isCurrentPosition ?? this.isCurrentPosition,
      skills: skills ?? this.skills,
    );
  }
}

class AddPositionInitial extends AddPositionState {
   final AddPositionFormData formData;
   const AddPositionInitial(this.formData);
}

class AddPositionLoading extends AddPositionState {
   final AddPositionFormData formData;
   const AddPositionLoading(this.formData);
}

class AddPositionSuccess extends AddPositionState {
  const AddPositionSuccess();
}

class AddPositionFailure extends AddPositionState {
  final AddPositionFormData formData;
  final String message;
  const AddPositionFailure(this.formData, this.message);
}