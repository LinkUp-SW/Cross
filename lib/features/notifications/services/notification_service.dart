import '../model/notification_model.dart';

abstract class NotificationService {
  Future<List<NotificationModel>> fetchNotifications();
}