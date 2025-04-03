import 'package:link_up/features/my-network/model/connections_screen_model.dart';

class ConnectionsScreenState {
  final List<ConnectionsCardModel>? connections;
  final int? connectionsCount;
  final String? nextCursor;
  final bool isLoading;
  final bool isError;

  const ConnectionsScreenState({
    this.connections,
    this.connectionsCount,
    this.nextCursor,
    required this.isError,
    required this.isLoading,
  });

  factory ConnectionsScreenState.initial() {
    return const ConnectionsScreenState(
      connections: null,
      connectionsCount: null,
      nextCursor: null,
      isError: false,
      isLoading: true,
    );
  }

  ConnectionsScreenState copyWith({
    final List<ConnectionsCardModel>? connections,
    final int? connectionsCount,
    final String? nextCursor,
    final bool? isLoading,
    final bool? isError,
  }) {
    return ConnectionsScreenState(
      connections: connections ?? this.connections,
      connectionsCount: connectionsCount ?? this.connectionsCount,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}
