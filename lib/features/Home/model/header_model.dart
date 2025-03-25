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


  HeaderModel.initial()
      : profileImage = 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
        name = 'John Doe',
        connectionDegree = '3rd',
        about = 'Hello this is john doe a special person',
        timeAgo = DateTime.now(),
        edited = false,
        visibility = Visibilities.anyone;

    
    HeaderModel copyWith({
    String? profileImage,
    String? name,
    String? connectionDegree,
    String? about,
    DateTime? timeAgo,
    bool? edited,
    Visibilities? visibility,
  }) {
    return HeaderModel(
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      connectionDegree: connectionDegree ?? this.connectionDegree,
      about: about ?? this.about,
      timeAgo: timeAgo ?? this.timeAgo,
      edited: edited ?? this.edited,
      visibility: visibility ?? this.visibility,
    );
  }

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
