import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/connections_screen_model.dart';
import 'package:link_up/features/my-network/services/connections_screen_services.dart';
import 'package:link_up/features/my-network/state/connections_screen_state.dart';

class ConnectionsScreenViewModel extends StateNotifier<ConnectionsScreenState> {
  final ConnectionsScreenServices _connectionsScreenServices;

  ConnectionsScreenViewModel(
    this._connectionsScreenServices,
  ) : super(
          ConnectionsScreenState.initial(),
        );

  Future<void> getConnectionsCount() async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final response = await _connectionsScreenServices.getConnectionsCount();
      final connectionsCount = response['number_of_connections'];

      state = state.copyWith(
        isLoading: false,
        connectionsCount: connectionsCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> getConnectionsList(Map<String, dynamic>? queryParameters) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final response = await _connectionsScreenServices.getConnectionsList(
          queryParameters: queryParameters);

      // Parse the connections from the response
      final List<ConnectionsCardModel> connections =
          (response['connections'] as List)
              .map((connection) => ConnectionsCardModel.fromJson(connection))
              .toList();
      final nextCursor = response['nextCursor'];
      state = state.copyWith(
          isLoading: false, connections: connections, nextCursor: nextCursor);
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> removeConnection(String userId) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      await _connectionsScreenServices.removeConnection(userId);

      // Remove the connection from the connections list
      if (state.connections != null) {
        final updatedConnections = state.connections!
            .where((connection) => connection.cardId != userId)
            .toList();

        state =
            state.copyWith(isLoading: false, connections: updatedConnections);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}

final connectionsScreenViewModelProvider =
    StateNotifierProvider<ConnectionsScreenViewModel, ConnectionsScreenState>(
  (ref) {
    return ConnectionsScreenViewModel(
      ref.read(connectionsScreenServicesProvider),
    );
  },
);
