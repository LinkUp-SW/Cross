import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/comment_model.dart';

class ActivityModel {
  ActitvityType type;
  String actorUserName;
  String actorName;
  String actorProfileImage;
  CommentModel comment = CommentModel.initial();
  bool show;

  ActivityModel({
    required this.type,
    required this.actorUserName,
    required this.actorName,
    required this.actorProfileImage,
    this.show = false,
  });

  ActivityModel.fromJson(Map<String, dynamic> json)
      : type = ActitvityType.getActivityType(json['type']),
        actorUserName = json['actor_username'],
        actorName = json['actor_name'],
        show = true,
        actorProfileImage = json['actor_picture'],
        comment = json['type'] == 'comment'
            ? CommentModel.fromJson(json['comment'])
            : CommentModel.initial();

  ActivityModel.initial()
      : type = ActitvityType.none,
        actorUserName = 'userName',
        actorName = 'actorName',
        show = false,
        actorProfileImage =
            'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
        comment = CommentModel.initial();
}
