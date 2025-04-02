import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class SentInvitationsTabState {
  final List<InvitationsCardModel>? sent;
  final bool isLoading;
  final bool error;

  const SentInvitationsTabState({
    this.sent,
    required this.isLoading,
    required this.error,
  });

  factory SentInvitationsTabState.initial() {
    return const SentInvitationsTabState(
      sent: null,
      isLoading: true,
      error: false,
    );
  }

  SentInvitationsTabState copyWith({
    final List<InvitationsCardModel>? sent,
    bool? isLoading,
    bool? error,
  }) {
    return SentInvitationsTabState(
      sent: sent ?? this.sent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
