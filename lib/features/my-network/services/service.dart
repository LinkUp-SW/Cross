import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';

class MyNetworkScreenServices {
  final BaseService _baseService;

  const MyNetworkScreenServices(this._baseService);

  Future<Map<String, dynamic>> _getMyNetworkData(String endpoint,
      {int limit = 4, int offset = 0}) async {
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    try {
      final response = await _baseService.get(endpoint, queryParams);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFromUniversity() => _getMyNetworkData('');
  Future<Map<String, dynamic>> getRecentActivity() => _getMyNetworkData('');
  Future<Map<String, dynamic>> getFollowThesePeople() => _getMyNetworkData('');
  Future<Map<String, dynamic>> getTopEmergingCreators() =>
      _getMyNetworkData('');
  Future<Map<String, dynamic>> getYourCommunityFollow() =>
      _getMyNetworkData('');
  Future<Map<String, dynamic>> getBecauseYouFollow() => _getMyNetworkData('');
  Future<Map<String, dynamic>> getMoreSuggestions() => _getMyNetworkData('');
}

final myNetworkScreenServicesProvider =
    Provider<MyNetworkScreenServices>((ref) {
  return MyNetworkScreenServices(ref.read(baseServiceProvider));
});
