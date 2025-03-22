enum NotificationFilter { All, Jobs, Mentions, Posts } // Define enum

class NotificationModel {
  final String id;
  final String profilePic;
  final String name;
  final String message;
  final String time;
  final NotificationFilter type; // Ensure this matches the enum
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.profilePic,
    required this.name,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      profilePic: profilePic,
      name: name,
      message: message,
      time: time,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  // for API response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      profilePic: json['profilePic'] as String,
      name: json['name'] as String,
      message: json['message'] as String,
      time: json['time'] as String,
      type: json['type'] as NotificationFilter,
      isRead: json['isRead'] as bool,
    );
  }
}
