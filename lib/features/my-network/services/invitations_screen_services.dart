import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class InvitationsScreenServices {
  final BaseService _baseService;

  const InvitationsScreenServices(this._baseService);

  // Get all received invitations
  Future<Map<String, dynamic>> getReceivedInvitations() async {
    try {
      final response = await _baseService
          .get(ExternalEndPoints.receivedConnectionInvitations);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to get received connection invitations: ${response.statusCode}');
    } catch (e) {
      print("Error fetching received connection invitations: $e");
      rethrow;
    }
  }

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
      print("Error fetching sent connection invitations: $e");
      rethrow;
    }
  }

  // Accept an invitation
  Future<Map<String, dynamic>> acceptInvitation(String userId) async {
    try {
      final response = await _baseService.post(
          ExternalEndPoints.acceptConnectionInvitation,
          {}, // Empty body or data payload
          {'user_id': userId} // Route parameters
          );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to accept received connection invitation: ${response.statusCode}');
    } catch (e) {
      print("Error accept received connection invitations: $e");
      rethrow;
    }
  }

  // Ignore an invitation
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
      print("Error ignore received connection invitations: $e");
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
      print("Error withdraw sent connection invitations: $e");
      rethrow;
    }
  }
}

final invitationsScreenServicesProvider =
    Provider<InvitationsScreenServices>((ref) {
  return InvitationsScreenServices(ref.read(baseServiceProvider));
});
