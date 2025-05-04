enum NotificationFilter { All, Posts, Connections } // Define enum

class NotificationModel {
  final String id;
  final String senderId;
  final String firstName;
  final String lastName;
  final String profilePhoto;
  final String content;
  final String createdAt;
  final NotificationFilter type;
  final bool isRead;
  final String referenceId;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
    required this.content,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    required this.referenceId,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      senderId: senderId,
      firstName: firstName,
      lastName: lastName,
      profilePhoto: profilePhoto,
      content: content,
      createdAt: createdAt,
      type: type,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId,
    );
  }

  // for API response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>;

    return NotificationModel(
      id: json['id'] as String,
      senderId: sender['id'] as String,
      firstName: sender['firstName'] as String,
      lastName: sender['lastName'] as String,
      profilePhoto: sender['profilePhoto'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      type: _parseNotificationType(json['type']),
      isRead: json['isRead'] as bool,
      referenceId: json['referenceId'] as String,
    );
  }

  static NotificationFilter _parseNotificationType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'posts':
        return NotificationFilter.Posts;
      case 'connections':
        return NotificationFilter.Connections;
      default:
        return NotificationFilter.All;
    }
  }
}
