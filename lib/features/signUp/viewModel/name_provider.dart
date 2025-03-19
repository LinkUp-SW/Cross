import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/model/name_model.dart';
import 'package:link_up/features/signUp/services/name_service.dart';
import 'package:link_up/features/signUp/state/name_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';

final nameServiceProvider = Provider((ref) => NameService());

final nameProvider = StateNotifierProvider<NameNotifier, NameState>((ref) {
  final service = ref.watch(nameServiceProvider);
  final signUpNotifier =
      ref.read(signUpProvider.notifier); // Access the global signup instance
  return NameNotifier(service, signUpNotifier);
});

class NameNotifier extends StateNotifier<NameState> {
  final NameService _nameService;
  final SignUpNotifier _signUpNotifier;

  NameNotifier(this._nameService, this._signUpNotifier) : super(NameInitial());

  Future<void> setName(String firstName, String lastName) async {
    try {
      state = NameLoading();
      final success = await _nameService
          .setName(NameModel(firstName: firstName, lastName: lastName));
      if (success == true) {
        // Update the global signup instance
        _signUpNotifier.updateUserData(
            firstName: firstName, lastName: lastName);
        print(
            "First Name: ${_signUpNotifier.state.fisrtName}, Last Name: ${_signUpNotifier.state.lastName}");
        state = NameValid();
      } else {
        state = NameInvalid("Failed to set name");
      }
    } catch (e) {
      state = NameInvalid("Failed to set name");
    }
  }

  String? validateName(String? name, String? definer) {
    if (name == null || name.isEmpty || name.length < 3) {
      return "Please choose a correct $definer ";
    }
    return null;
  }
}
