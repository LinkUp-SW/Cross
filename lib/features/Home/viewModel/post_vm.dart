import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
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

  Future<void> getPost(String id) async {
    log('getPost called with id: $id');
    final BaseService service = BaseService();
    return await service.get('api/v1/post/posts/:postId',
        routeParameters: {"postId": id}).then((value) {
      log(value.body);
      final data = jsonDecode(value.body);
      state = PostModel.fromJson(data['post']);
    }).catchError((error) {
      log('$error');
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      log('timeout');
      throw Exception('Request timed out');
    });
  }

  Future<Map<String, List<ReactionTileModel>>> fetchReactions() async {
    final BaseService service = BaseService();
    return service.get('api/v1/post/reaction/:postId', routeParameters: {
      "postId": state.id,
    }, queryParameters: {
      "cursor": '0',
      "limit": '10',
      "targetType": "Post",
      "commentId": null,
      "specificReaction": null,
    }).then((value) {
      final data = jsonDecode(value.body);
      log(data.toString());
      final reactions = data['reactions']['reactions'] as List<dynamic>;
      Map<String, List<ReactionTileModel>> reactionMap = {};
      for (var reaction in reactions) {
        String reactionType = reaction['reaction'];
        if (reactionMap.containsKey(reactionType)) {
          reactionMap[reactionType]!.add(ReactionTileModel.fromJson(reaction));
        } else {
          reactionMap[reactionType] = [ReactionTileModel.fromJson(reaction)];
        }
      }
      reactionMap['All'] =
          reactions.map((e) => ReactionTileModel.fromJson(e)).toList();
      return reactionMap;
    }).catchError((error) {
      log('$error');
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      log('timeout');
      throw Exception('Request timed out');
    });
  }
}

final postProvider = StateNotifierProvider<PostNotifier, PostModel>((ref) {
  return PostNotifier();
});
