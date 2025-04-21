// File: features/profile/services/service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/core/constants/endpoints.dart';

class ProfileService extends BaseService {

  Future<bool> addEducation(EducationModel education) async {
    final String userId = InternalEndPoints.userId;

    if (userId.isEmpty) {
      throw Exception("User ID not available. Please log in again.");
    }

    const String educationEndpointTemplate = ExternalEndPoints.addEducation;

    try {
      final response = await post(
        educationEndpointTemplate,
        body: education.toJson(),
        routeParameters: {
          'u_id': userId
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add education (Status Code: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});