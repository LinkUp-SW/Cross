import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> startSubscriptionPaymentSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final startSubscriptionPaymentSessionResponse =
          await _subscriptionManagementScreenServices
              .startSubscriptionPaymentSession();
      final Uri uri = Uri.parse(startSubscriptionPaymentSessionResponse['url']);
      final launched = await launchUrl(uri);

      if (!launched) {
        throw Exception('Could not open payment page. Please try again.');
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      log('Error redirecting to subscription payment session $e');
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> cancelPremiumSubscription() async {
    state = state.copyWith(isLoading: true);
    try {
      await _subscriptionManagementScreenServices
          .cancelSubscriptionPaymentSession();

      await getCurrentPlan();
    } catch (e) {
      log("Error toggling switch button $e");
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> resumePremiumSubscription() async {
    state = state.copyWith(isLoading: true);
    try {
      await _subscriptionManagementScreenServices
          .resumeSubscriptionPaymentSession();

      await getCurrentPlan();
    } catch (e) {
      log("Error toggling switch button $e");
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
