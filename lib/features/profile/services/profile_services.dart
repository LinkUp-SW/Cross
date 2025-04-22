import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/profile_model.dart';

class ProfileService extends BaseService {

  Future<UserProfile> getUserProfile(String userId) async {
    const String endpointTemplate = 'api/v1/user/profile/bio/:user_id';

    try {
      print('Fetching profile for user ID: $userId');
      final response = await get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );

      print('API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return UserProfile.fromJson(jsonData);
      } else {
        print('API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load profile (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      throw Exception('Failed to load user profile.');
    }
  }

  Future<bool> addEducation(EducationModel education) async {
    final String userId = InternalEndPoints.userId;

    if (userId.isEmpty) {
      throw Exception("User ID not available. Please log in again.");
    }

    const String educationEndpoint = ExternalEndPoints.addEducation;

    try {
      final response = await post(
        educationEndpoint,
        body: education.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
         log('Add Education Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add education (Status Code: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('Error adding education: $e');
      rethrow;
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});