import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class ReceivedInvitationsTabState {
  final List<InvitationsCardModel>? received;
  final bool isLoading;
  final bool error;

  const ReceivedInvitationsTabState({
    this.received,
    required this.isLoading,
    required this.error,
  });

  factory ReceivedInvitationsTabState.initial() {
    return const ReceivedInvitationsTabState(
      received: null,
      isLoading: true,
      error: false,
    );
  }

  ReceivedInvitationsTabState copyWith({
    final List<InvitationsCardModel>? received,
    bool? isLoading,
    bool? error,
  }) {
    return ReceivedInvitationsTabState(
      received: received ?? this.received,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
