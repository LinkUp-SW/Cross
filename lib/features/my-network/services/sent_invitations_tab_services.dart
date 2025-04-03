import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class SentInvitationsTabServices {
  final BaseService _baseService;

  const SentInvitationsTabServices(this._baseService);

  // Get all sent invitations
  Future<Map<String, dynamic>> getSentInvitations() async {
    try {
      final response =
          await _baseService.get(ExternalEndPoints.sentConnectionInvitations);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to get sent connection invitations: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // Withdraw an invitation
  Future<Map<String, dynamic>> withdrawInvitation(String userId) async {
    try {
      final response = await _baseService.delete(
          ExternalEndPoints.withdrawConnectionInvitation, {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to withdraw sent connection invitation: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

final sentInvitationsTabServicesProvider = Provider<SentInvitationsTabServices>(
  (ref) {
    return SentInvitationsTabServices(
      ref.read(baseServiceProvider),
    );
  },
);
