// lib/features/admin_panel/services/users_service.dart
import 'dart:convert';
import 'dart:developer';

import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/admin_panel/model/users_model.dart';

class UserService extends BaseService {
  /// Fetches a page of users, starting at [cursor], up to [limit] items.
  Future<List<UserModel>> fetchUsers({
    int cursor = 0,
    int limit = 10,
  }) async {
    final response = await get(
      'api/v1/admin/users',
      queryParameters: {
        'cursor': cursor,
        'limit': limit,
      },
    );
    log('Response: ${response.body}');
    final raw = jsonDecode(response.body)['data']['users'] as List;
    return raw.map((u) => UserModel.fromJson(u)).toList();
  }

  Future<void> addUser(UserModel user) async {
    final response = post(
      'api/v1/admin/users',
      body: user.toJson(),
    );
    log('Response: ${response}');
  }

  Future<void> deleteUser(String id) async {
    // simulate backend call
    try {
      final response = await delete(
        'api/v1/admin/users/:id',
        {
          'id': id,
        },
      );
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to delete user");
    }
  }
}
