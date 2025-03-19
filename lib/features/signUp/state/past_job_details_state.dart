import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class PastJobDetailsState {
  bool amStudent;
  bool showJobLocationField;
  TextEditingController locationController;
  TextEditingController schoolController;
  TextEditingController startDateController;
  TextEditingController pastJobTitleController;
  TextEditingController pastJobLocationController;
  FocusNode pastJobTitleFocusNode;

  PastJobDetailsState({
    required this.amStudent,
    required this.showJobLocationField,
    required this.locationController,
    required this.schoolController,
    required this.startDateController,
    required this.pastJobTitleController,
    required this.pastJobLocationController,
    required this.pastJobTitleFocusNode,
  });

  PastJobDetailsState copyWith({
    bool? amStudent,
    bool? showJobLocationField,
    TextEditingController? locationController,
    TextEditingController? schoolController,
    TextEditingController? startDateController,
    TextEditingController? pastJobTitleController,
    TextEditingController? pastJobLocationController,
    FocusNode? pastJobTitleFocusNode,
  }) {
    return PastJobDetailsState(
      amStudent: amStudent ?? this.amStudent,
      showJobLocationField: showJobLocationField ?? this.showJobLocationField,
      locationController: locationController ?? this.locationController,
      schoolController: schoolController ?? this.schoolController,
      startDateController: startDateController ?? this.startDateController,
      pastJobTitleController: pastJobTitleController ?? this.pastJobTitleController,
      pastJobLocationController: pastJobLocationController ?? this.pastJobLocationController,
      pastJobTitleFocusNode: pastJobTitleFocusNode ?? this.pastJobTitleFocusNode,
    );
  }
}

class PastJobDetailsNotifier extends StateNotifier<PastJobDetailsState> {
  PastJobDetailsNotifier()
      : super(PastJobDetailsState(
          amStudent: false,
          showJobLocationField: false,
          locationController: TextEditingController(),
          schoolController: TextEditingController(),
          startDateController: TextEditingController(),
          pastJobTitleController: TextEditingController(),
          pastJobLocationController: TextEditingController(),
          pastJobTitleFocusNode: FocusNode(),
        )) {
    state.pastJobTitleFocusNode.addListener(_onPastJobTitleFocusChange);
  }

  void updateStartDate(String date) {
    state = state.copyWith(startDateController: TextEditingController(text: date));
  }
  void _onPastJobTitleFocusChange() {
    if (!state.pastJobTitleFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        state = state.copyWith(
          showJobLocationField: state.pastJobTitleController.text.isNotEmpty,
        );
      });
    }
  }

  void toggleStudentStatus() {
    state = state.copyWith(amStudent: !state.amStudent);
  }

  void dispose() {
    state.locationController.dispose();
    state.schoolController.dispose();
    state.startDateController.dispose();
    state.pastJobTitleController.dispose();
    state.pastJobLocationController.dispose();
    state.pastJobTitleFocusNode.dispose();
  }
}

final pastJobDetailsProvider =
    StateNotifierProvider<PastJobDetailsNotifier, PastJobDetailsState>(
        (ref) => PastJobDetailsNotifier());