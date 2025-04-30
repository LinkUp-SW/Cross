import 'dart:convert';
import 'dart:developer';

import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';

Future<int> deletePost(String postId) async {
  final BaseService service = BaseService();
  final response = await service.delete('api/v1/post/posts/:postId', {
    "postId": postId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Post deleted successfully: ${response.body}');
  } else {
    log('Failed to delete post');
  }
  return response.statusCode;
}

Future<void> savePost(String postId) async {
  final BaseService service = BaseService();
  final response = await service.post('api/v1/post/save-post', body: {
    "postId": postId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Post saved successfully: ${response.body}');
  } else {
    log('Failed to save post');
  }
}

Future<void> unsavePost(String postId) async {
  final BaseService service = BaseService();
  final response = await service.delete('api/v1/post/save-post',null,body:  {
    "postId": postId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Post unsaved successfully: ${response.body}');
  } else {
    log('Failed to unsave post');
  }
}

Future<void> followUser(String userId) async {
  final BaseService service = BaseService();
  final response =
      await service.post('api/v1/user/follow/:userId', routeParameters: {
    "userId": userId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('User followed successfully: ${response.body}');
  } else {
    log('Failed to follow user');
  }
}

Future<void> unfollowUser(String userId) async {
  final BaseService service = BaseService();
  final response = await service.delete('api/v1/user/unfollow/:userId', {
    "userId": userId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('User unfollowed successfully: ${response.body}');
  } else {
    log('Failed to unfollow user');
  }
}

Future<void> connectToUser(String userId) async {
  final BaseService service = BaseService();
  final response =
      await service.post('api/v1/user/connect/:userId', routeParameters: {
    "userId": userId,
  });
  if (response.statusCode == 200) {
    log('User connected successfully: ${response.body}');
  } else {
    log('Failed to connect to user');
  }
}

Future<Set> getSavedPosts(int? cursor) async {
  final BaseService service = BaseService();
  final response =
      await service.get('api/v1/post/save-post', queryParameters: {
    'limit': '10',
    'cursor': cursor.toString(),
  });
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    log('Response: ${response.statusCode} - ${response.body}');
    List<PostModel> posts = (data['posts'] as List)
        .map((post) => PostModel.fromJson(post))
        .toList();
    
    cursor = data['nextCursor'];
    log('Cursor: $cursor');
    for (var post in posts) {
      post.saved = true;
    }
    return {posts,cursor};
  } else {
    log('Failed to retrieve saved posts');
    return {};
  }
}

Future<Set> getUserPosts(int? cursor,String userId) async {
  final BaseService service = BaseService();
  final response = await service.get('api/v1/post/posts/user/:userId', routeParameters: {
    "userId": userId,
  },
  queryParameters: {
    'limit': '10',
    'cursor': cursor.toString(),
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<PostModel> posts = (data['posts'] as List)
        .map((post) => PostModel.fromJson(post))
        .toList();
    cursor = data['nextCursor'];
    log('Cursor: $cursor');
    return {posts,cursor};
  } else {
    log('Failed to retrieve user posts');
    return {};
  }
}

Future<void> reportPost(String postId) async {
  final BaseService service = BaseService();
  final response =
      await service.post('api/v1/post/report/:postId', routeParameters: {
    "postId": postId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Post reported successfully: ${response.body}');
  } else {
    log('Failed to report post');
  }
}

Future<void> reportComment(String commentId) async {
  final BaseService service = BaseService();
  final response = await service
      .post('api/v1/post/report-comment/:commentId', routeParameters: {
    "commentId": commentId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Comment reported successfully: ${response.body}');
  } else {
    log('Failed to report comment');
  }
}

Future<Map<String,dynamic>> setReaction(String postId, Reaction reaction, String type,{String? commentId}) async {
  final BaseService service = BaseService();
  final response =
      await service.post('api/v1/post/reaction/:postId', routeParameters: {
    "postId": postId,
  }, body: {
    "reaction": Reaction.getReactionString(reaction).toLowerCase(),
    "target_type": type,
    "comment_id": commentId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    log('Failed to set reaction');
    return {};
  }
}

Future<Map<String,dynamic>> removeReaction(String postId, String type,{String? commentId}) async {
  final BaseService service = BaseService();
  final response = await service.delete('api/v1/post/reaction/:postId', {
    "postId": postId,
  }, body: {
    "comment_id": commentId,
    "target_type": type,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    log('Failed to remove reaction');
    return {};
  }
}
