import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier() : super([]);

  void addPosts(List<PostModel> posts) {
    state = [...state, ...posts];
  }

  void removePost(PostModel post) {
    state = state.where((element) => element.id != post.id).toList();
  }

  void updatePost(PostModel post) {
    state = state.map((e) => e.id == post.id ? post : e).toList();
  }

  void setPosts(List<PostModel> posts) {
    state = posts;
  }

  Future<void> refreshPosts() {
    return fetchPosts().then((value) {
      state = value;
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
            id: '1',
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
    StateNotifierProvider<PostsNotifier, List<PostModel>>((ref) {
  return PostsNotifier();
});
