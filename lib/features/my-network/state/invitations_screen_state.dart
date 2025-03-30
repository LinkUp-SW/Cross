import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class InvitationsScreenState {
  final List<InvitationsCardModel>? received;
  final List<InvitationsCardModel>? sent;
  final bool isLoading;
  final bool error;

  const InvitationsScreenState({
    this.received,
    this.sent,
    required this.isLoading,
    required this.error,
  });

  factory InvitationsScreenState.initial() {
    return const InvitationsScreenState(
      received: null,
      sent: null,
      isLoading: true,
      error: false,
    );
  }

  InvitationsScreenState copyWith({
    final List<InvitationsCardModel>? received,
    final List<InvitationsCardModel>? sent,
    bool? isLoading,
    bool? error,
  }) {
    return InvitationsScreenState(
      received: received ?? this.received,
      sent: sent ?? this.sent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
