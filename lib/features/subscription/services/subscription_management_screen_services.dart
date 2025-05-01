import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';

class SubscriptionManagementScreenServices {
  final BaseService _baseService;

  const SubscriptionManagementScreenServices(this._baseService);

  Future<Map<String, dynamic>> getCurrentPlan() async {
    try {
      final response = await _baseService.get(ExternalEndPoints.currentPlan);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        log('Response body: ${response.body}');
        return body;
      }
      throw Exception(
          'Failed to get current plan details, Status code: ${response.statusCode} Response body: ${response.body}');
    } catch (e) {
      log('Error getting current plan details $e');
      rethrow;
    }
  }
}

final subscriptionManagementScreenServicesProvider =
    Provider<SubscriptionManagementScreenServices>(
  (ref) {
    return SubscriptionManagementScreenServices(
      ref.read(baseServiceProvider),
    );
  },
);
