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
      String? address,
      String? dateOfBirth,
      String? gender}) {
    state = SignUpModel(
      fisrtName: firstName ?? state.fisrtName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
      password: password ?? state.password,
      phoneNumber: phoneNumber ?? state.phoneNumber,
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
