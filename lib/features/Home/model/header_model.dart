import 'package:link_up/features/Home/home_enums.dart';

class HeaderModel {
  String userId;
  String profileImage;
  String name;
  String connectionDegree;
  String about;
  DateTime timeAgo;
  bool edited;
  Visibilities visibilityPost;
  Visibilities visibilityComments;

  HeaderModel({
    required this.userId,
    required this.profileImage,
    required this.name,
    required this.connectionDegree,
    required this.about,
    required this.timeAgo,
    required this.visibilityPost,
    required this.visibilityComments,
    this.edited = false,
  });

  HeaderModel.fromJson(Map<String, dynamic> json)
      : profileImage = json['author']['profilePicture'],
        userId = json['author']['username'],
        name = '${json['author']['firstName']}  ${json['author']['lastName']}',
        connectionDegree = json['author']['connectionDegree'] ?? '3rd+',
        about = json['author']['headline'],
        timeAgo =json['date'] != null ? DateTime.fromMillisecondsSinceEpoch(json['date']*1000,) : DateTime.now(),
        edited = json['isEdited'] ?? false,
        visibilityComments = Visibilities.getVisibility(json['comments_disabled'] ?? 'anyone'),
        visibilityPost =  Visibilities.getVisibility(json['public_post'] == true ? 'anyone': 'connectionsOnly');

  Map<String, dynamic> toJson() => {
        'profileImage': profileImage,
        'userId' : userId,
        'name': name,
        'connectionDegree': connectionDegree,
        'about': about,
        'timeAgo': timeAgo.toString(),
        'edited': edited,
        'visibilityPost': visibilityPost.toString(),
        'visibilityComment' : visibilityComments.toString(),
      };


  HeaderModel.initial()
      : profileImage = 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
        userId = '1',
        name = 'John Doe',
        connectionDegree = '3rd',
        about = 'Hello this is john doe a special person',
        timeAgo = DateTime.now(),
        edited = false,
        visibilityComments = Visibilities.anyone,
        visibilityPost = Visibilities.anyone;

    
    HeaderModel copyWith({
    String? profileImage,
    String? userId,
    String? name,
    String? connectionDegree,
    String? about,
    DateTime? timeAgo,
    bool? edited,
    Visibilities? visibilityPost,
    Visibilities? visibilityComments,
  }) {
    return HeaderModel(
      userId: userId ?? this.userId,
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      connectionDegree: connectionDegree ?? this.connectionDegree,
      about: about ?? this.about,
      timeAgo: timeAgo ?? this.timeAgo,
      edited: edited ?? this.edited,
      visibilityComments: visibilityComments ?? this.visibilityComments,
      visibilityPost: visibilityPost ?? this.visibilityPost,
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
