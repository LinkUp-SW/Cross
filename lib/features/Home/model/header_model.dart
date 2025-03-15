import 'package:link_up/features/Home/home_enums.dart';

class HeaderModel {
  String profileImage;
  String name;
  String connectionDegree;
  String about;
  DateTime timeAgo;
  bool edited;
  Visibilities? visibility;

  HeaderModel({
    required this.profileImage,
    required this.name,
    required this.connectionDegree,
    required this.about,
    required this.timeAgo,
    this.visibility,
    this.edited = false,
  });

  HeaderModel.fromJson(Map<String, dynamic> json)
      : profileImage = json['profileImage'],
        name = json['name'],
        connectionDegree = json['connectionDegree'],
        about = json['about'],
        timeAgo = DateTime.parse(json['timeAgo']),
        edited = json['edited'] ?? false,
        visibility = Visibilities.getVisibility(json['visibility'] ?? 'anyone');

  Map<String, dynamic> toJson() => {
        'profileImage': profileImage,
        'name': name,
        'connectionDegree': connectionDegree,
        'about': about,
        'timeAgo': timeAgo.toString(),
        'edited': edited,
        'visibility': visibility.toString(),
      };

  String getTime() {
    final now = DateTime.now();
    final difference = now.difference(timeAgo);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}d';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
