import 'dart:developer';

import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/post_model.dart';

Future<void> deletePost(String postId) async {
  final BaseService service = BaseService();
  final response = await service.delete('api/v1/post/delete-post', {
    "postId": postId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Post deleted successfully: ${response.body}');
  } else {
    log('Failed to delete post');
  }
}

Future<void> savePost(String postId) async {
  final BaseService service = BaseService();
  final response = await service.post('api/v1/post/save-post',body: {
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
  final response = await service.delete('api/v1/post/save-post', {
    "postId": postId,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Post unsaved successfully: ${response.body}');
  } else {
    log('Failed to unsave post');
  }
}

Future<List<PostModel>> getSavedPosts() async {
  final BaseService service = BaseService();
  final response = await service.get('api/v1/post/saved-post',queryParameters: {
    'limit': 10,
    'cursor': 0,
  });

  log('Response: ${response.statusCode} - ${response.body}');
  if (response.statusCode == 200) {
    log('Saved posts retrieved successfully: ${response.body}');
    List<PostModel> posts = (response.body as List)
        .map((post) => PostModel.fromJson(post))
        .toList();
    return posts;
  } else {
    log('Failed to retrieve saved posts');
    return [];
  }
}