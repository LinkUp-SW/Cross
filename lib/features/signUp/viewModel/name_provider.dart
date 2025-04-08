import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/services/name_service.dart';
import 'package:link_up/features/signUp/state/name_state.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';

final nameServiceProvider = Provider((ref) => NameService());

final nameProvider = StateNotifierProvider<NameNotifier, NameState>((ref) {
  final signUpNotifier =
      ref.read(signUpProvider.notifier); // Access the global signup instance
  return NameNotifier( signUpNotifier);
});

class NameNotifier extends StateNotifier<NameState> {
  final SignUpNotifier _signUpNotifier;

  NameNotifier( this._signUpNotifier) : super(NameInitial());

  void setName(String firstName, String lastName) {
    _signUpNotifier.updateUserData(firstName: firstName, lastName: lastName);
  }

  String? validateName(String? name, String? definer) {
    if (name == null || name.isEmpty || name.length < 3) {
      return "Please choose a correct $definer ";
    }
    return null;
  }
}
