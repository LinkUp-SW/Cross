//page data model (any needed classes)
class NotificationModel {
  final String id;
  final String profilePic;
  final String name;
  final String message;
  final String time;
  final String type; // for filtering the notfications 
  final bool isRead; // To track unread notifications

  NotificationModel({
    required this.id,
    required this.profilePic,
    required this.name,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}