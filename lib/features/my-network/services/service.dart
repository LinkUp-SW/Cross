import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';

class GrowTabServices {
  final BaseService _baseService;

  const GrowTabServices(this._baseService);

  Future<Map<String, dynamic>> _getMyNetworkGrowTabData(String endpoint,
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

  Future<Map<String, dynamic>> getFromCurrentPosition() =>
      _getMyNetworkGrowTabData('');
  Future<Map<String, dynamic>> getRecentActivity() =>
      _getMyNetworkGrowTabData('');
  Future<Map<String, dynamic>> getFollowThesePeople() =>
      _getMyNetworkGrowTabData('');
  Future<Map<String, dynamic>> getTopEmergingCreators() =>
      _getMyNetworkGrowTabData('');
  Future<Map<String, dynamic>> getYourCommunityFollow() =>
      _getMyNetworkGrowTabData('');
  Future<Map<String, dynamic>> getBecauseYouFollow() =>
      _getMyNetworkGrowTabData('');
  Future<Map<String, dynamic>> getMoreSuggestions() =>
      _getMyNetworkGrowTabData('');
}

final growTabServicesProvider = Provider<GrowTabServices>((ref) {
  return GrowTabServices(ref.read(baseServiceProvider));
});
