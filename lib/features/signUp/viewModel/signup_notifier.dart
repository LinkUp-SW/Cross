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
      String? companyName,
      String? school,
      String? startDate,
      String? address,
      String? location,
      String? dateOfBirth,
      String? gender}) {
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
      companyName: companyName ?? state.companyName,
      school: school ?? state.school,
      startDate: startDate ?? state.startDate,
      location: location ?? state.location,
      address: address ?? state.address,
      dateOfBirth: dateOfBirth ?? state.dateOfBirth,
      gender: gender ?? state.gender,
    );
  }

  // Submit final data to backend
  Future<bool> submitSignUp() async {
    return await SignUpService().sendDataToBackend(state);
  }
}
