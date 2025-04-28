import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';

class PeopleTabServices {
  final BaseService _baseService;

  const PeopleTabServices(this._baseService);

  Future<Map<String, dynamic>> getPeopleSearch({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _baseService.get(
        ExternalEndPoints.peopleSearch,
        queryParameters: queryParameters,
      );
      log('People Search Response Body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to get search people list with status code: ${response.statusCode} and body: ${response.body}');
    } catch (e) {
      log('Error fetching people search: $e');
      rethrow;
    }
  }
}

final peopleTabServicesProvider = Provider<PeopleTabServices>(
  (ref) {
    return PeopleTabServices(
      ref.read(baseServiceProvider),
    );
  },
);
