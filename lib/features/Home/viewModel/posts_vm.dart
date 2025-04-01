import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class PostState{
  bool showUndo = false;
  PostModel post;
  PostState({this.showUndo = false,required this.post});
}

class PostsNotifier extends StateNotifier<List<PostState>> {
  PostsNotifier() : super([]);

  void addPosts(List<PostModel> posts) {
    
    state = [...state, ...posts.map((e) => PostState(post: e))];
  }

  void removePost(String id) {
    state = state.where((element) => element.post.id != id).toList();
  }

  void showUndo(String id) {
    state = state.map((e) => e.post.id == id ? PostState(post: e.post, showUndo: !e.showUndo) : e).toList();
  }

  void updatePost(PostModel post) {
    state = state.map((e) => e.post.id == post.id ? PostState(post: post,showUndo: e.showUndo) : e).toList();
  }

  void setPosts(List<PostModel> posts) {
    state = posts.map((e) => PostState(post: e)).toList();
  }

  Future<void> refreshPosts() {
    return fetchPosts().then((value) {
      state = value.map((e) => PostState(post: e)).toList();
    });
  }

  Future<List<PostModel>> fetchPosts() {
    //TODO: Implement fetchPosts form backend
    // Take note that the repost with thoughts could cause problems so check should be done
    return Future.delayed(
      const Duration(seconds: 5),
      () {
        return List.generate(
          6,
          (index) => PostModel(
            id: '${index + 1}',
            header: HeaderModel(
              profileImage:
                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
              name: 'John Doe',
              connectionDegree: 'johndoe',
              about: 'About John Doe',
              timeAgo: DateTime.now(),
              visibility: Visibilities.anyone,
            ),
            text: 'This is a post',
            media: Media(
              post: index % 6 == 5
                  ? PostModel.initial().copyWith(
                      media: Media(type: MediaType.pdf, urls: [
                      'https://www.sldttc.org/allpdf/21583473018.pdf'
                    ]))
                  : null,
              type: index % 6 == 1
                  ? MediaType.video
                  : index % 6 == 2
                      ? MediaType.image
                      : index % 6 == 3
                          ? MediaType.images
                          : index % 6 == 4
                              ? MediaType.pdf
                              : index % 6 == 5
                                  ? MediaType.post
                                  : MediaType.link,
              urls: index % 6 == 1
                  ? [
                      'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4'
                    ]
                  : index % 6 == 2
                      ? [
                          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'
                        ]
                      : index % 6 == 3
                          ? [
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'
                            ]
                          : index % 6 == 4
                              ? [
                                  'https://www.sldttc.org/allpdf/21583473018.pdf'
                                ]
                              : ['https://pub.dev/packages/any_link_preview'],
            ),
            reactions: 10,
            comments: 50,
            reposts: 5,
            reaction: Reaction.none,
            isCompany: index % 6 == 3,
            isAd: index % 6 == 4
          ),
        );
      },
    );
  }
}

final postsProvider =
    StateNotifierProvider<PostsNotifier, List<PostState>>((ref) {
  return PostsNotifier();
});
