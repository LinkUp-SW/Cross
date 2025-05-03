// lib/features/profile/services/user_activity_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart'; // Assuming endpoints are defined here

class UserActivityService {
  final BaseService _baseService;

  // Define the endpoint template (adjust if necessary)
  // Example: '/api/v1/user/posts/:userId'
  // Ensure this matches your actual API route structure
  static const String _userPostsEndpointTemplate = 'api/v1/post/posts/user/:userId';

  const UserActivityService(this._baseService);

  /// Fetches posts for a specific user with pagination.
  Future<Map<String, dynamic>> getUserPosts({
    required String userId,
    Map<String, dynamic>? queryParameters, // For limit, cursor
  }) async {
    log('UserActivityService: Fetching posts for user ID: $userId with params: $queryParameters');
    try {
      final response = await _baseService.get(
        _userPostsEndpointTemplate,
        routeParameters: {'userId': userId}, // Pass userId as route parameter
        queryParameters: queryParameters,
      );

      log('UserActivityService: API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
         log('UserActivityService: Fetched ${data['posts']?.length ?? 0} posts. Next cursor: ${data['next_cursor']}');
        return data; // Contains 'posts' list and 'next_cursor'
      } else {
        log('UserActivityService: Failed to load user posts. Status Code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load user posts (Status code: ${response.statusCode})');
      }
    } catch (e, stackTrace) {
      log('UserActivityService: Error fetching user posts: $e', stackTrace: stackTrace);
      rethrow; // Rethrow the error to be caught by the ViewModel
    }
  }
}

// Riverpod provider for the service
final userActivityServiceProvider = Provider<UserActivityService>((ref) {
  final baseService = ref.watch(baseServiceProvider); // Assuming baseServiceProvider exists
  return UserActivityService(baseService);
});