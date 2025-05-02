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

        return body;
      }
      throw Exception(
          'Failed to get current plan details, Status code: ${response.statusCode} Response body: ${response.body}');
    } catch (e) {
      log('Error getting current plan details $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> startSubscriptionPaymentSession() async {
    try {
      final response = await _baseService.post(
        ExternalEndPoints.subscriptionPaymentSession,
        body: {"platform": "android"},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        return body;
      }
      throw Exception(
          'Failed to start subscription payment session, Status code: ${response.statusCode} Response body: ${response.body}');
    } catch (e) {
      log('Error starting subscription payment session $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelSubscriptionPaymentSession() async {
    try {
      final response = await _baseService.post(
        ExternalEndPoints.cancelPremiumSubscription,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        return body;
      }
      throw Exception(
          'Failed to cancel premium subscription, Status code: ${response.statusCode} Response body: ${response.body}');
    } catch (e) {
      log('Error cancelling premium subscription $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resumeSubscriptionPaymentSession() async {
    try {
      final response = await _baseService.post(
        ExternalEndPoints.resumePremiumSubscription,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        return body;
      }
      throw Exception(
          'Failed to resume premium subscription, Status code: ${response.statusCode} Response body: ${response.body}');
    } catch (e) {
      log('Error resuming premium subscription $e');
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
