import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/model/reaction_tile_model.dart';

class PostNotifier extends StateNotifier<PostModel> {
  PostNotifier() : super(PostModel.initial());

  void setPost(PostModel post) {
    state = post;
  }

  String getPostId() {
    return state.id;
  }

  void fetchPost(String id) {
    Future.delayed(const Duration(seconds: 2), () {
      state = PostModel.initial();
    });
  }

  Future<Map<String, List<ReactionTileModel>>> fetchReactions() {
    return Future.delayed(const Duration(seconds: 5), () {
      return List.generate(100, (index) {
        return ReactionTileModel(
          header: HeaderModel(
            userId: index.toString(),
            profileImage:
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
            name: 'John Doe',
            connectionDegree: 'johndoe',
            about: 'About John Doe',
            timeAgo: DateTime.now(),
            visibilityPost: Visibilities.anyone,
            visibilityComments: Visibilities.anyone,
          ),
          reaction: Reaction.values[index % 6],
        );
      });
    }).then((value) {
      return {
        'All': value,
        for (var reaction in Reaction.values)
          if (reaction != Reaction.none)
            Reaction.getReactionString(reaction):
                value.where((element) => element.reaction == reaction).toList()
      };
    });
  }
}

final postProvider = StateNotifierProvider<PostNotifier, PostModel>((ref) {
  return PostNotifier();
});
