import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/subscription/services/subscription_management_screen_services.dart';
import 'package:link_up/features/subscription/state/subscription_management_screen_state.dart';
import 'package:link_up/features/subscription/model/subscription_card_model.dart';

class SubscriptionManagementScreenViewModel
    extends StateNotifier<SubscriptionManagementScreenState> {
  final SubscriptionManagementScreenServices
      _subscriptionManagementScreenServices;

  SubscriptionManagementScreenViewModel(
      this._subscriptionManagementScreenServices)
      : super(
          SubscriptionManagementScreenState.initial(),
        );
  Future<void> getCurrentPlan() async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final currentPlanResponse =
          await _subscriptionManagementScreenServices.getCurrentPlan();

      final currentPlan =
          SubscriptionCardModel.fromJson(currentPlanResponse['subscription']);

      state = state.copyWith(
        isLoading: false,
        currentPlan: currentPlan,
      );
    } catch (e) {
      log("Error converting response to subscription card model $e");
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}

final subscriptionManagementScreenViewModelProvider = StateNotifierProvider<
    SubscriptionManagementScreenViewModel, SubscriptionManagementScreenState>(
  (ref) {
    return SubscriptionManagementScreenViewModel(
      ref.read(subscriptionManagementScreenServicesProvider),
    );
  },
);
