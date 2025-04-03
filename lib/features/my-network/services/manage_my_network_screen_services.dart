import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class ManageMyNetworkScreenServices {
  final BaseService _baseService;

  const ManageMyNetworkScreenServices(this._baseService);

  // Get connections count
  Future<Map<String, dynamic>> getManageMyNetworkScreenCounts() async {
    try {
      final response = await _baseService
          .get(ExternalEndPoints.connectionsAndFollowingsCounts);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to get connections count: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

final manageMyNetworkScreenServicesProvider =
    Provider<ManageMyNetworkScreenServices>((ref) {
  return ManageMyNetworkScreenServices(ref.read(baseServiceProvider));
});
