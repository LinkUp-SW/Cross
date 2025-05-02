import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/search/services/email_confirmation_pop_up_services.dart';
import 'package:link_up/features/search/state/email_confirmation_pop_up_state.dart';

class EmailConfirmationPopUpViewModel
    extends Notifier<EmailConfirmationPopUpState> {
  @override
  EmailConfirmationPopUpState build() {
    return EmailConfirmationPopUpState();
  }

  Future<void> sendConnectionRequest(
    String userId, {
    Map<String, dynamic>? body,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref
          .read(emailConfirmationPopUpServicesProvider)
          .sendConnectionRequest(userId, body: body);
      await clearErrorMessage();
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: "Email did not match!");
      log('Error sending connection request: $e');
    }
  }

  Future<void> validateEmail(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: "Email cannot be empty");
      return;
    }

    // Simple regex for basic email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: "Please enter a valid email");
      return;
    }

    await clearErrorMessage();
    return;
  }

  Future<void> clearErrorMessage() async {
    state =
        state.copyWith(errorMessage: null, isLoading: false, isError: false);
  }
}

final emailConfirmationPopUpViewModelProvider = NotifierProvider<
    EmailConfirmationPopUpViewModel, EmailConfirmationPopUpState>(
  () {
    return EmailConfirmationPopUpViewModel();
  },
);
