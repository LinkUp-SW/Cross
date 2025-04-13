import 'dart:convert';

import 'package:link_up/core/services/base_service.dart';

class PastJobDetailsService extends BaseService {
  Future<dynamic> geteducation(Map<String, dynamic>? queryParameters) async {
    try {
      final response = await get('api/v1/search/education/:query',
          routeParameters: queryParameters);
      print(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getcompany(Map<String, dynamic>? queryParameters) async {
    try {
      final response = await get('api/v1/search/company/:query',
          routeParameters: queryParameters);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
}
