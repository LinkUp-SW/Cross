import 'dart:convert';
import 'dart:developer';

import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';

Future<int> deletePost(String postId) async {
  final BaseService service = BaseService();
  try {
    final response = await service.delete('api/v2/post/posts/:postId', {
      "postId": postId,
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post deleted successfully: ${response.body}');
    } else {
      log('Failed to delete post');
    }
    return response.statusCode;
  } catch (e) {
    log('Error deleting post: $e');
    return 500; // Return a default error code if an exception occurs
  }
}

Future<void> savePost(String postId) async {
  final BaseService service = BaseService();
  try {
    final response = await service.post('api/v2/post/save-post', body: {
      "postId": postId,
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post saved successfully: ${response.body}');
    } else {
      log('Failed to save post');
    }
  } catch (e) {
    log('Error saving post: $e');
  }
}

Future<void> unsavePost(String postId) async {
  final BaseService service = BaseService();
  try {
    final response = await service.delete('api/v2/post/save-post', null, body: {
      "postId": postId,
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post unsaved successfully: ${response.body}');
    } else {
      log('Failed to unsave post');
    }
  } catch (e) {
    log('Error unsaving post: $e');
  }
}

Future<void> followUser(String userId) async {
  final BaseService service = BaseService();
  try {
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
  } catch (e) {
    log('Error following user: $e');
  }
}

Future<void> unfollowUser(String userId) async {
  final BaseService service = BaseService();
  try {
    final response = await service.delete('api/v1/user/unfollow/:userId', {
      "userId": userId,
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('User unfollowed successfully: ${response.body}');
    } else {
      log('Failed to unfollow user');
    }
  } catch (e) {
    log('Error unfollowing user: $e');
  }
}

Future<void> connectToUser(String userId) async {
  final BaseService service = BaseService();
  try {
    final response =
        await service.post('api/v2/user/connect/:userId', routeParameters: {
      "userId": userId,
    });
    if (response.statusCode == 200) {
      log('User connected successfully: ${response.body}');
    } else {
      log('Failed to connect to user');
    }
  } catch (e) {
    log('Error connecting to user: $e');
  }
}

Future<Set> getSavedPosts(int? cursor) async {
  final BaseService service = BaseService();
  try {
    final response =
        await service.get('api/v2/post/save-post', queryParameters: {
      'limit': '10',
      'cursor': cursor.toString(),
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Response: ${response.statusCode} - ${response.body}');
      List<PostModel> posts = (data['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList();

      cursor = data['next_cursor'];
      log('Cursor: $cursor');
      for (var post in posts) {
        post.saved = true;
      }
      return {posts, cursor};
    } else {
      log('Failed to retrieve saved posts');
      return {};
    }
  } catch (e) {
    log('Error retrieving saved posts: $e');
    return {};
  }
}

Future<Set> getUserPosts(int? cursor, String userId) async {
  final BaseService service = BaseService();
  try {
    final response =
        await service.get('api/v2/post/posts/user/:userId', routeParameters: {
      "userId": userId,
    }, queryParameters: {
      'limit': '10',
      'cursor': cursor.toString(),
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<PostModel> posts = (data['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
      cursor = data['next_cursor'];
      log('Cursor: $cursor');
      return {posts, cursor};
    } else {
      log('Failed to retrieve user posts');
      return {};
    }
  } catch (e) {
    log('Error retrieving user posts: $e');
    return {};
  }
}

Future<void> reportPost(String id,String type,ReportReasonEnum reason) async {
  final BaseService service = BaseService();
  try {
    final response =
        await service.post('api/v1/admin/report', body: {
      "contentRef": id,
      "contentType": type,
      "reason": ReportReasonEnum.getReasonString(reason),
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post reported successfully: ${response.body}');
    } else {
      log('Failed to report post');
    }
  } catch (e) {
    log('Error reporting post: $e');
  }
}

Future<Map<String, dynamic>> setReaction(
    String postId, Reaction reaction, String type,
    {String? commentId}) async {
  final BaseService service = BaseService();
  try {
    final response =
        await service.post('api/v2/post/reaction/:postId', routeParameters: {
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
  } catch (e) {
    log('Error setting reaction: $e');
    return {};
  }
}

Future<Map<String, dynamic>> removeReaction(String postId, String type,
    {String? commentId}) async {
  final BaseService service = BaseService();
  try {
    final response = await service.delete('api/v2/post/reaction/:postId', {
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
  } catch (e) {
    log('Error removing reaction: $e');
    return {};
  }
}

Future<bool> repostInstantly(String postId) async {
  final BaseService service = BaseService();
  try {
    final response = await service.post('api/v2/post/posts', body: {
      "mediaType": "post",
      "media": [postId],
      "postType": "Repost instant"
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post reposted successfully: ${response.body}');
      return true;
    } else {
      log('Failed to repost post');
      return false;
    }
  } catch (e) {
    log('Error reposting post: $e');
    return false;
  }
}
