import 'package:link_up/features/my-network/model/connections_screen_model.dart';

class ConnectionsScreenState {
  final Set<ConnectionsCardModel>? connections;
  final int? connectionsCount;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isError;

  const ConnectionsScreenState({
    this.connections,
    this.connectionsCount,
    this.nextCursor,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isError,
  });

  factory ConnectionsScreenState.initial() {
    return const ConnectionsScreenState(
      connections: null,
      connectionsCount: null,
      nextCursor: null,
      isLoading: true,
      isLoadingMore: false,
      isError: false,
    );
  }

  ConnectionsScreenState copyWith({
    final Set<ConnectionsCardModel>? connections,
    final int? connectionsCount,
    final String? nextCursor,
    final bool? isLoading,
    final bool? isLoadingMore,
    final bool? isError,
  }) {
    return ConnectionsScreenState(
      connections: connections ?? this.connections,
      connectionsCount: connectionsCount ?? this.connectionsCount,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isError: isError ?? this.isError,
    );
  }
}
