import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:link_up/features/signUp/model/phone_number_model.dart';
import 'package:link_up/features/signUp/services/phone_number_service.dart';
import 'package:link_up/features/signUp/state/phone_number_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';
import 'package:link_up/shared/functions.dart';

final phoneNumberServiceProvider = Provider((ref) => PhoneNumberService());

final phoneNumberProvider =
    StateNotifierProvider<PhoneNumberNotifier, PhoneNumberState>((ref) {
  final service = ref.watch(phoneNumberServiceProvider);
  final signUpNotifier = ref.read(signUpProvider.notifier);
  return PhoneNumberNotifier(service, signUpNotifier);
});

class PhoneNumberNotifier extends StateNotifier<PhoneNumberState> {
  final PhoneNumberService _phoneNumberService;
  final SignUpNotifier _signUpNotifier;

  PhoneNumberNotifier(this._phoneNumberService, this._signUpNotifier)
      : super(PhoneNumberinitial());

  Future<void> setPhoneNumber(String countryCode, String phoneNumber) async {
    try {
      state = LoadingPhoneNumber();
      final success = await _phoneNumberService.setPhoneNumber(
          PhoneNumberModel(countryCode: countryCode, number: phoneNumber));
      final secondSuccess = await _phoneNumberService.sendphonenumber();

      if (success == true && secondSuccess == true) {
        state = PhoneNumberValid();

        _signUpNotifier.updateUserData(
            phoneNumber: phoneNumber,
            countryCode: countryCode,
            country: (countryCode));
        print('${_signUpNotifier.state.email}');
        print(
            "name: ${_signUpNotifier.state.firstName} ${_signUpNotifier.state.lastName}");
        print("Phone Number: ${_signUpNotifier.state.phoneNumber}");
      } else if (success == false) {
        state = PhoneNumberInvalid("Failed to set phone number");
      } else if (secondSuccess == false) {
        state =
            PhoneNumberInvalid("Failed to send phone number for verfication");
      } else {
        state = PhoneNumberInvalid("Failed to set phone number");
      }
    } catch (e) {
      state = PhoneNumberInvalid("Failed to set phone number");
    }
  }
}
