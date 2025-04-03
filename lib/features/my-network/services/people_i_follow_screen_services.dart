import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class PeopleIFollowScreenServices {
  final BaseService _baseService;

  const PeopleIFollowScreenServices(this._baseService);

  Future<Map<String, dynamic>> getConnectionsCount() async {
    try {
      final response =
          await _baseService.get(ExternalEndPoints.connectionsCount);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to get connections count: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConnectionsList({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.connectionsList,
        queryParameters: queryParameters,
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

final peopleIFollowScreenServicesProvider =
    Provider<PeopleIFollowScreenServices>(
  (ref) {
    return PeopleIFollowScreenServices(
      ref.read(baseServiceProvider),
    );
  },
);
