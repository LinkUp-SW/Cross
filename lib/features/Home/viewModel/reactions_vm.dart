import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/reaction_tile_model.dart';

class ReactionsState {
  Map<Reaction, int> reactionsCount = {};
  String postId = '';
  String commentId = '';
  String targetType = 'Post';
  Map<Reaction, int?> cursor =
      Reaction.values.asMap().map((key, value) => MapEntry(value, 0));
  Map<Reaction, List<ReactionTileModel>> reactions =
      Reaction.values.asMap().map((key, value) => MapEntry(value, []));

  ReactionsState({
    this.postId = '',
    this.commentId = '',
    this.targetType = 'Post',
  });

  ReactionsState.initial();
}

class ReactionsNotifier extends StateNotifier<ReactionsState> {
  ReactionsNotifier() : super(ReactionsState.initial());

  void setPost(String postId) {
    state.postId = postId;
    state.targetType = 'Post';
  }

  void setComment(String commentId, String postId) {
    state.postId = postId;
    state.commentId = commentId;
    state.targetType = 'Comment';
  }

  void clear() {
    state.reactionsCount = {};
    state.postId = '';
    state.commentId = '';
    state.targetType = 'Post';
    state.cursor =
        Reaction.values.asMap().map((key, value) => MapEntry(value, 0));
    state.reactions =
        Reaction.values.asMap().map((key, value) => MapEntry(value, []));
  }

  Future<void> fetchReactions(Reaction reaction) async {
    final BaseService service = BaseService();
    return service.get('api/v1/post/reaction/:postId', routeParameters: {
      "postId": state.postId,
    }, queryParameters: {
      "cursor": state.cursor[reaction].toString(),
      "limit": '20',
      "targetType": state.targetType,
      "commentId": state.commentId,
      "specificReaction": reaction == Reaction.none
          ? null
          : Reaction.getReactionString(reaction).toLowerCase(),
    }).then((value) {
      final data = jsonDecode(value.body)['reactions'];
      log(data.toString());
      final reactions = data['reactions'] as List<dynamic>;
      state.reactions[reaction]?.addAll(
          reactions.map((e) => ReactionTileModel.fromJson(e)).toList());
      if (reaction == Reaction.none) {
        state.reactionsCount[Reaction.none] = data['totalCount'];
        state.reactionsCount = Map<Reaction, int>.fromEntries(
        [MapEntry(Reaction.none, data['totalCount']),
          ...(data['reactionCounts'] as Map).map(
            (key, value) => MapEntry(Reaction.getReaction(key), value as int),
          ).entries]
        );
        
        final sortedEntries = state.reactionsCount.entries.toList()
          ..sort((a, b) {
            return b.value.compareTo(a.value);
          });
        state.reactionsCount = Map.fromEntries(sortedEntries);
      }
      state.cursor[reaction] = data['nextCursor'] as int?;
    }).catchError((error) {
      log('$error');
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      log('timeout');
      throw Exception('Request timed out');
    });
  }
}

final reactionsProvider =
    StateNotifierProvider<ReactionsNotifier, ReactionsState>(
  (ref) => ReactionsNotifier(),
);
