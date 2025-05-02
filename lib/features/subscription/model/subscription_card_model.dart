class SubscriptionCardModel {
  final String plan;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final bool? autoRenewal;

  const SubscriptionCardModel(
      {required this.plan,
      this.subscriptionEndDate,
      this.subscriptionStartDate,
      this.autoRenewal});

  SubscriptionCardModel copyWith({
    final String? plan,
    final String? subscriptionStartDate,
    final String? subscriptionEndDate,
    final bool? autoRenewal,
  }) {
    return SubscriptionCardModel(
      plan: plan ?? this.plan,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
    );
  }

  factory SubscriptionCardModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCardModel(
      plan: json['plan'],
      subscriptionEndDate: json['subscription_ends_at'],
      subscriptionStartDate: json['subscription_started_at'],
      autoRenewal: !json['cancel_at_period_end'],
    );
  }
}
