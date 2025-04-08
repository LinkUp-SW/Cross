import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class PeopleIFollowScreenServices {
  final BaseService _baseService;

  const PeopleIFollowScreenServices(this._baseService);

  Future<int> getFollowingsCount() async {
    try {
      final response = await _baseService
          .get(ExternalEndPoints.connectionsAndFollowingsCounts);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['number_of_following'];
      }
      throw Exception('Failed to get followings count: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFollowingsList({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.followingsList,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to get followings list: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unfollow(String userId) async {
    try {
      final response = await _baseService
          .delete(ExternalEndPoints.unfollow, {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to unfollow ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

final peopleIFollowScreenServicesProvider =
    Provider<PeopleIFollowScreenServices>(
  (ref) {
    return PeopleIFollowScreenServices(
      ref.read(baseServiceProvider),
    );
  },
);
