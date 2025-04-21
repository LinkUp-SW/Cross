import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class ReceivedInvitationsTabServices {
  final BaseService _baseService;

  const ReceivedInvitationsTabServices(this._baseService);

  Future<Map<String, dynamic>> getReceivedInvitations({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.receivedConnectionInvitations,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to get received connection invitations: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptInvitation(String userId) async {
    try {
      final response = await _baseService.post(
          ExternalEndPoints.acceptConnectionInvitation,
          routeParameters: {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to accept received connection invitation: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> ignoreInvitation(String userId) async {
    try {
      final response = await _baseService.delete(
          ExternalEndPoints.ignoreConnectionInvitation, {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to ignore received connection invitation: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

final receivedInvitationsTabServicesProvider =
    Provider<ReceivedInvitationsTabServices>(
  (ref) {
    return ReceivedInvitationsTabServices(
      ref.read(baseServiceProvider),
    );
  },
);
