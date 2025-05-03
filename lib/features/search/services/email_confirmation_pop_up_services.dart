import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';

class EmailConfirmationPopUpServices {
  final BaseService _baseService;

  const EmailConfirmationPopUpServices(this._baseService);

  Future<Map<String, dynamic>> sendConnectionRequest(
    String userId, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _baseService.post(
        ExternalEndPoints.connect,
        body: body,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to send connection request: ${response.body} , status code: ${response.statusCode}');
    } catch (e) {
      log('Error sending connection request: $e');
      rethrow;
    }
  }
}

final emailConfirmationPopUpServicesProvider =
    Provider<EmailConfirmationPopUpServices>(
  (ref) {
    return EmailConfirmationPopUpServices(
      ref.read(baseServiceProvider),
    );
  },
);
