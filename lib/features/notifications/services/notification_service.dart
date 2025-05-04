import '../model/notification_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/endpoints.dart';

class NotificationService {
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      // Handle the leading slash in the endpoint to avoid double slashes
      final endpoint = ExternalEndPoints.getnotifiacations.startsWith('/')
          ? ExternalEndPoints.getnotifiacations.substring(1)
          : ExternalEndPoints.getnotifiacations;

      final url = '${ExternalEndPoints.baseUrl}$endpoint';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
       
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NotificationModel.fromJson(item)).toList();
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

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer ${yourAuthToken}',
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

  Future<int> getUnreadNotificationsCount() async {
    try {
      final endpoint = ExternalEndPoints.getunreadnotifications.startsWith('/')
          ? ExternalEndPoints.getunreadnotifications.substring(1)
          : ExternalEndPoints.getunreadnotifications;

      final url = '${ExternalEndPoints.baseUrl}$endpoint';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer ${yourAuthToken}',
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
