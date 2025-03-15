import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class PostNotifier extends StateNotifier<PostModel> {
  PostNotifier()
      : super(PostModel.fromJson({
          "id": "1",
          "header": {
            "profileImage":
                "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
            "name": "John Doe",
            "connectionDegree": "johndoe",
            "about": "About John Doe",
            "timeAgo": DateTime.now().toIso8601String(),
            "visibility": "anyone"
          },
          "text": "This is a post",
          "media": {
            "type": "image",
            "urls": [
              "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg"
            ]
          },
          "reactions": 10,
          "comments": 0,
          "reposts": 1,
          "reaction": "celebrate"
        }));

  void setPost(PostModel post) {
    state = post;
  }
}

final postProvider = StateNotifierProvider<PostNotifier, PostModel>((ref) {
  return PostNotifier();
});
