import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class ConnectionsScreenServices {
  final BaseService _baseService;

  const ConnectionsScreenServices(this._baseService);

  Future<int> getConnectionsCount() async {
    try {
      final response = await _baseService
          .get(ExternalEndPoints.connectionsAndFollowingsCounts);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['number_of_connections'];
      }
      throw Exception(
          'Failed to get connections count: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConnectionsList({
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? routeParameters,
  }) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.connectionsList,
        queryParameters: queryParameters,
        routeParameters: routeParameters,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to get connections list: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> removeConnection(String userId) async {
    try {
      final response = await _baseService
          .delete(ExternalEndPoints.removeConnection, {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to remove connection ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

final connectionsScreenServicesProvider = Provider<ConnectionsScreenServices>(
  (ref) {
    return ConnectionsScreenServices(
      ref.read(baseServiceProvider),
    );
  },
);
