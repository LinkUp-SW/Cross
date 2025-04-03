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
      final connectionsCount =
          await _connectionsScreenServices.getConnectionsCount();

      state = state.copyWith(
        isLoading: false,
        connectionsCount: connectionsCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> getConnectionsList(
    Map<String, dynamic>? queryParameters,
  ) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final userId = await _connectionsScreenServices.getUserId();
      final response = await _connectionsScreenServices.getConnectionsList(
        queryParameters: queryParameters,
        routeParameters: {'user_id': userId},
      );

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

  Future<void> loadMoreConnections({
    required int paginationLimit,
  }) async {
    final currentState = state;

    // Don't load if we're already loading or at the end
    if (currentState.isLoadingMore || currentState.nextCursor == null) return;

    state = currentState.copyWith(isLoadingMore: true);

    try {
      final userId = await _connectionsScreenServices.getUserId();
      final response = await _connectionsScreenServices.getConnectionsList(
        queryParameters: {
          'limit': '$paginationLimit',
          'cursor': currentState.nextCursor,
        },
        routeParameters: {'user_id': userId},
      );

      final List<dynamic> connectionsData =
          response['connections'] as List? ?? [];
      // If server returns empty data, we've reached the end
      if (connectionsData.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final newConnections =
          connectionsData.map((c) => ConnectionsCardModel.fromJson(c)).toList();

      // Check for duplicates using cardId
      final existingIds =
          currentState.connections?.map((c) => c.cardId).toSet() ?? {};
      final uniqueNewConnections = newConnections
          .where((connection) => !existingIds.contains(connection.cardId))
          .toList();

      // If we got no unique results despite getting data, we're at the end
      if (uniqueNewConnections.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final List<ConnectionsCardModel> allConnections = [
        ...currentState.connections ?? [],
        ...uniqueNewConnections
      ];

      state = currentState.copyWith(
        connections: allConnections,
        nextCursor: response['nextCursor'],
        isLoadingMore: false,
      );
    } catch (e) {
      state = currentState.copyWith(isLoadingMore: false);
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

        state = state.copyWith(
          isLoading: false,
          connections: updatedConnections,
          connectionsCount: updatedConnections.length,
        );
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
