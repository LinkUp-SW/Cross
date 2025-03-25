import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/state/past_job_details_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';

final pastJobDetailProvider =
    StateNotifierProvider<PastJobDetailsNotifier, PastJobDetailsState>((ref) {
  final signUpNotifier =
      ref.read(signUpProvider.notifier); // Access the global signup instance
  return PastJobDetailsNotifier(signUpNotifier);
});

class PastJobDetailsNotifier extends StateNotifier<PastJobDetailsState> {
  final SignUpNotifier _signUpNotifier;
  DateTime? selectedDate;

  String? validateJobTitle(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Please enter a valid job title';
    }
    return null;
  }

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Please enter a valid company name';
    }
    return null;
  }

  String? validateJobDescription(String? value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return 'Please enter a valid job description';
    }
    return null;
  }

  Future<void> pickDate(context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      selectedDate = pickedDate;
    }
  }

  PastJobDetailsNotifier(this._signUpNotifier) : super(Job());

  void toggleStudentStatus() {
    if (state is Student) {
      state = Job();
    } else {
      state = Student();
    }
  }

  void setData(String location, String jobTitle, String companyName,
      String school, String startDate) async {
    if (state is Job) {
      _signUpNotifier.updateUserData(
        city: location,
        jobTitle: jobTitle,
        recentCompany: companyName,
        isStudent: false,
      );
      print(
          "${_signUpNotifier.state.firstName} ${_signUpNotifier.state.lastName}");
    } else {
      _signUpNotifier.updateUserData(
          location: location,
          school: school,
          startDate: startDate,
          isStudent: true);
    }

    try {
      state = PastJobDetailsLoading();
      final success = await _signUpNotifier.submitSignUp();

      if (success) {
        state = PastJobDetailsSuccess();
      } else {
        state = PastJobDetailsError("Failed to submit data");
      }
    } catch (e) {
      state = PastJobDetailsError("Failed to submit data");
    }
  }
}
