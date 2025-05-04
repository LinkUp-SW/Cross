import 'package:link_up/core/services/storage.dart';

import '../model/notification_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/endpoints.dart';

class NotificationService {
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      // Handle the leading slash in the endpoint to avoid double slashes
      final endpoint = ExternalEndPoints.getnotifications.startsWith('/')
          ? ExternalEndPoints.getnotifications.substring(1)
          : ExternalEndPoints.getnotifications;

      final url = '${ExternalEndPoints.baseUrl}$endpoint';
      final String? authToken = await _getAuthToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> notificationsData = responseData['notifications'] as List<dynamic>;

        return notificationsData.map((item) => NotificationModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      // Replace :notificationId in the endpoint with the actual ID
      String endpoint = ExternalEndPoints.marknotificationasread.replaceAll(':notificationId', notificationId);

      if (endpoint.startsWith('/')) {
        endpoint = endpoint.substring(1);
      }

      final url = '${ExternalEndPoints.baseUrl}$endpoint';

      // Get authentication token from secure storage or state management
      final String? authToken = await _getAuthToken();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Add auth header
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    return await getToken();
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final endpoint = ExternalEndPoints.getunreadnotifications.startsWith('/')
          ? ExternalEndPoints.getunreadnotifications.substring(1)
          : ExternalEndPoints.getunreadnotifications;

      final url = '${ExternalEndPoints.baseUrl}$endpoint';
      final String? authToken = await _getAuthToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] as int;
      } else {
        throw Exception('Failed to get unread notifications count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting unread notifications count: $e');
    }
  }
}
