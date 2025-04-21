enum NotificationFilter { All, Posts, Connections } // Define enum

class NotificationModel {
  final String id;
  final String profilePic;
  final String name;
  final String message;
  final String time;
  final NotificationFilter type; // Ensure this matches the enum
  final bool isRead;
  final String? postId; // Only set if the type is 'Posts'
  final String? userId; // Only set if the type is 'Connections'

  NotificationModel({
    required this.id,
    required this.profilePic,
    required this.name,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.postId, // Optional: Only for 'Posts' type
    this.userId, // Optional: Only for 'Connections' type
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
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
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
      type: NotificationFilter.values.firstWhere(
        (e) => e.toString() == 'NotificationFilter.${json['type']}',
      ),
      isRead: json['isRead'] as bool,
      postId: json['type'] == 'Posts' ? json['postId'] as String? : null,
      userId: json['type'] == 'Connections' ? json['userId'] as String? : null,
    );
  }
}
