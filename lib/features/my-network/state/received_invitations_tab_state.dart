import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class ReceivedInvitationsTabState {
  final List<InvitationsCardModel>? received;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool error;

  const ReceivedInvitationsTabState({
    this.received,
    this.nextCursor,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
  });

  factory ReceivedInvitationsTabState.initial() {
    return const ReceivedInvitationsTabState(
      received: null,
      nextCursor: null,
      isLoading: true,
      isLoadingMore: false,
      error: false,
    );
  }

  ReceivedInvitationsTabState copyWith({
    final List<InvitationsCardModel>? received,
    final String? nextCursor,
    final bool? isLoading,
    final bool? isLoadingMore,
    final bool? error,
  }) {
    return ReceivedInvitationsTabState(
      received: received ?? this.received,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
