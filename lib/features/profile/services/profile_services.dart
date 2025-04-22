import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/profile/model/contact_info_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/profile_model.dart';

class ProfileService extends BaseService {

  Future<UserProfile> getUserProfile(String userId) async {
    const String endpointTemplate = 'api/v1/user/profile/bio/:user_id';
    log('ProfileService: Fetching profile for UserProfile model, user ID: $userId');
    try {
      final response = await get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      log('ProfileService: getUserProfile API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return UserProfile.fromJson(jsonData);
      } else {
        log('ProfileService: getUserProfile API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load profile (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserProfile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchFullUserProfileJson(String userId) async {
     const String endpointTemplate = 'api/v1/user/profile/bio/:user_id';
     log('ProfileService: Fetching full profile JSON for user ID: $userId');
     try {
       final response = await get(
         endpointTemplate,
         routeParameters: {'user_id': userId},
       );
       log('ProfileService: fetchFullUserProfileJson API Response Status Code: ${response.statusCode}');
       if (response.statusCode == 200) {
         final Map<String, dynamic> jsonData = jsonDecode(response.body);
         log('ProfileService: Fetched full profile data JSON: ${jsonData.toString()}');
         return jsonData;
       } else {
         log('ProfileService: fetchFullUserProfileJson API Error: Status Code ${response.statusCode}, Body: ${response.body}');
         throw Exception('Failed to load profile JSON (Status code: ${response.statusCode})');
       }
     } catch (e) {
       log('ProfileService: Error fetching full profile data JSON: $e');
       rethrow;
     }
   }

  Future<ContactInfoModel> getContactInfo(String userId) async {
    log('ProfileService: Getting ContactInfoModel for user ID: $userId');
    try {
      final fullProfileJson = await fetchFullUserProfileJson(userId);
      final bio = fullProfileJson['bio'] as Map<String, dynamic>?;
      final contactInfoJson = bio?['contact_info'] as Map<String, dynamic>?;

      if (contactInfoJson != null) {
        log('ProfileService: Extracted contact_info JSON for ContactInfoModel: ${contactInfoJson.toString()}');
        return ContactInfoModel.fromJson(contactInfoJson);
      } else {
        log('ProfileService: contact_info not found in fetched data.');
        return ContactInfoModel.initial();
      }
    } catch (e) {
      log('ProfileService: Error in getContactInfo: $e');
      rethrow;
    }
  }

  Future<bool> updateContactInfo({
    required String userId,
    required ContactInfoModel updatedContactInfo,
    required Map<String, dynamic> originalBio
  }) async {
    const String endpoint = 'api/v1/user/update-user-profile';

    final Map<String, dynamic> updatedContactInfoJson = updatedContactInfo.toJson();

    final Map<String, dynamic> requestBio = Map<String, dynamic>.from(originalBio);
    requestBio['contact_info'] = updatedContactInfoJson;

    final Map<String, dynamic> requestBody = {'bio': requestBio};

    log('ProfileService: Updating contact info for user ID: $userId');
    log('ProfileService: Sending PUT request body: ${jsonEncode(requestBody)}');

    try {
      final response = await put(endpoint, requestBody);

      log('ProfileService: updateContactInfo API Response Status Code: ${response.statusCode}');
      log('ProfileService: updateContactInfo API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Contact info updated successfully.');
        return true;
      } else {
        log('ProfileService: Failed to update contact info. Status Code: ${response.statusCode}');
        String errorMessage = 'Failed to update contact info (Status code: ${response.statusCode})';
         try {
            final errorJson = jsonDecode(response.body);
            errorMessage = errorJson['message'] ?? errorMessage;
         } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error during updateContactInfo: $e');
      rethrow;
    }
  }

  Future<bool> addEducation(EducationModel education) async {
    final String userId = InternalEndPoints.userId;
    if (userId.isEmpty) {
      throw Exception("User ID not available. Please log in again.");
    }
    const String educationEndpoint = ExternalEndPoints.addEducation;
    log('ProfileService: Adding education for user ID: $userId');
    try {
      final response = await post(
        educationEndpoint,
        body: education.toJson(),
      );
      log('ProfileService: addEducation API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        log('ProfileService: Add Education Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add education (Status Code: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('ProfileService: Error adding education: $e');
      rethrow;
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});