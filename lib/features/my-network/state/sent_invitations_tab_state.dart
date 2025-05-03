import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class SentInvitationsTabState {
  final Set<InvitationsCardModel>? sent;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool error;

  const SentInvitationsTabState({
    this.sent,
    this.nextCursor,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
  });

  factory SentInvitationsTabState.initial() {
    return const SentInvitationsTabState(
      sent: null,
      nextCursor: null,
      isLoading: true,
      isLoadingMore: false,
      error: false,
    );
  }

  SentInvitationsTabState copyWith({
    final Set<InvitationsCardModel>? sent,
    final String? nextCursor,
    final bool? isLoading,
    final bool? isLoadingMore,
    final bool? error,
  }) {
    return SentInvitationsTabState(
      sent: sent ?? this.sent,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
