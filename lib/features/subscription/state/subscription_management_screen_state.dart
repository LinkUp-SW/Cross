import 'package:link_up/features/subscription/model/subscription_card_model.dart';

class SubscriptionManagementScreenState {
  final SubscriptionCardModel currentPlan;
  final bool isLoading;
  final bool isError;

  const SubscriptionManagementScreenState({
    required this.currentPlan,
    this.isLoading = true,
    this.isError = false,
  });

  factory SubscriptionManagementScreenState.initial() {
    return SubscriptionManagementScreenState(
      currentPlan: SubscriptionCardModel(
        plan: 'free',
        subscriptionEndDate: null,
        subscriptionStartDate: null,
        autoRenewal: null,
      ),
      isError: false,
      isLoading: true,
    );
  }

  SubscriptionManagementScreenState copyWith({
    final SubscriptionCardModel? currentPlan,
    final bool? isLoading,
    final bool? isError,
  }) {
    return SubscriptionManagementScreenState(
      currentPlan: currentPlan ?? this.currentPlan,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
