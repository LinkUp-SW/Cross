import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/model/signup_global_model.dart';
import 'package:link_up/features/signUp/services/signup_service.dart';

final signUpProvider =
    StateNotifierProvider<SignUpNotifier, SignUpModel>((ref) {
  return SignUpNotifier();
});

class SignUpNotifier extends StateNotifier<SignUpModel> {
  SignUpNotifier() : super(SignUpModel());

  // Update any field dynamically
  void updateUserData(
      {String? firstName,
      String? lastName,
      String? email,
      String? password,
      String? phoneNumber,
      String? countryCode,
      String? country,
      String? city,
      String? jobTitle,
      Map<String, dynamic>? recentCompany,
      Map<String, dynamic>? school,
      String? startDate,
      String? address,
      String? location,
      bool? isStudent}) {
    state = SignUpModel(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
      password: password ?? state.password,
      phoneNumber: phoneNumber ?? state.phoneNumber,
      countryCode: countryCode ?? state.countryCode,
      country: country ?? state.country,
      city: city ?? state.city,
      jobTitle: jobTitle ?? state.jobTitle,
      recentCompany: recentCompany ?? state.recentCompany,
      school: school ?? state.school,
      startDate: startDate ?? state.startDate,
      location: location ?? state.location,
      address: address ?? state.address,
      isStudent: isStudent ?? state.isStudent,
    );
  }

  // Submit final data to backend
  Future<bool> submitSignUp() async {
    return await SignUpService().sendDataToBackend(state);
  }
}
