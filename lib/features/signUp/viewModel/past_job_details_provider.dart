import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/services/past_job_details_service.dart';
import 'package:link_up/features/signUp/state/past_job_details_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';

pastjobdetailsserviceprovider() {
  return Provider((ref) => PastJobDetailsService());
}

final pastJobDetailProvider =
    StateNotifierProvider<PastJobDetailsNotifier, PastJobDetailsState>((ref) {
  final service = ref.watch(pastjobdetailsserviceprovider());
  final signUpNotifier =
      ref.read(signUpProvider.notifier); // Access the global signup instance
  return PastJobDetailsNotifier(signUpNotifier, service);
});

final schoolResultsProvider = StateProvider<List<String>>((ref) => []);
final companyResultsProvider = StateProvider<List<String>>((ref) => []);

class PastJobDetailsNotifier extends StateNotifier<PastJobDetailsState> {
  final SignUpNotifier _signUpNotifier;
  final PastJobDetailsService _service;

  DateTime? selectedDate;
  List<Map<String, dynamic>> schoolResults = [];
  List<Map<String, dynamic>> companyResults = [];

  PastJobDetailsNotifier(this._signUpNotifier, this._service)
      : super(PastJobDetailsInitial());

  Future<void> getSchools(String query, WidgetRef ref) async {
    try {
      final result = await _service.geteducation({"query": query});
      if (result['data'] != null) {
        final list = List<Map<String, dynamic>>.from(result['data']);
        ref.read(schoolResultsProvider.notifier).state =
            list.map((e) => e['name']?.toString() ?? '').toList();
      } else {
        ref.read(schoolResultsProvider.notifier).state = [];
      }
    } catch (_) {
      ref.read(schoolResultsProvider.notifier).state = [];
    }
  }

  Future<void> getcompany(String query, WidgetRef ref) async {
    try {
      final result = await _service.getcompany({"query": query});
      if (result['data'] != null) {
        final list = List<Map<String, dynamic>>.from(result['data']);
        ref.read(companyResultsProvider.notifier).state =
            list.map((e) => e['name']?.toString() ?? '').toList();
      } else {
        ref.read(companyResultsProvider.notifier).state = [];
      }
    } catch (_) {
      ref.read(companyResultsProvider.notifier).state = [];
    }
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

  void setData(bool amStudent, String country, String city, String jobTitle,
      String companyName, String school, String startDate) async {
    try {
      state = PastJobDetailsLoading();

      if (amStudent) {
        _signUpNotifier.updateUserData(
            country: country,
            city: city,
            school: school,
            startDate: startDate,
            isStudent: true);
      } else {
        _signUpNotifier.updateUserData(
            country: country,
            city: city,
            jobTitle: jobTitle,
            recentCompany: companyName,
            isStudent: false);
      }

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
