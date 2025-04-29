import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/profile/model/contact_info_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/features/profile/model/position_model.dart'; 
import 'package:mime/mime.dart';

class ProfileService extends BaseService {

  Future<UserProfile> getUserProfile(String userId) async {
    const String endpointTemplate = 'api/v1/user/profile/bio/:user_id';
    log('ProfileService: Fetching profile for UserProfile model, user ID: $userId');
    try {
      final response = await super.get(
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
       final response = await super.get(
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
  Future<List<EducationModel>> getUserEducation(String userId) async {
   const String endpointTemplate = ExternalEndPoints.getUserEducation; //'api/v1/user/profile/education/:user_id';
   log('ProfileService: Fetching education for user ID: $userId');
   try {
     final response = await super.get( // Use super.get
       endpointTemplate,
       routeParameters: {'user_id': userId},
     );
     log('ProfileService: getUserEducation API Response Status Code: ${response.statusCode}');
     if (response.statusCode == 200) {
       final Map<String, dynamic> jsonData = jsonDecode(response.body);
       final List<dynamic> educationJsonList = jsonData['education'] as List? ?? [];
       final List<EducationModel> educations = educationJsonList
           .map((eduJson) => eduJson is Map<String, dynamic> ? EducationModel.fromJson(eduJson) : null)
           .whereType<EducationModel>()
           .toList();
       return educations;
     } else {
       log('ProfileService: getUserEducation API Error: Status Code ${response.statusCode}, Body: ${response.body}');
       throw Exception('Failed to load education (Status code: ${response.statusCode})');
     }
   } catch (e) {
     log('ProfileService: Error in getUserEducation: $e');
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

  Future<bool> updateProfilePhoto(XFile imageFile) async {
    const String endpoint = 'api/v1/user/profile/profile-picture';
    final Uri uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    final String? token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    log('ProfileService: Uploading profile photo: ${imageFile.path} to $uri');

    try {
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      String? mimeType = lookupMimeType(imageFile.path);
      MediaType? contentType;
      if (mimeType != null) {
        final parts = mimeType.split('/');
        if (parts.length == 2) {
           contentType = MediaType(parts[0], parts[1]);
        }
      }

      request.files.add(await http.MultipartFile.fromPath(
         'profilePicture',
         imageFile.path,
         contentType: contentType,
      ));

      log('ProfileService: Sending multipart request...');
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      log('ProfileService: Upload API Response Status Code: ${response.statusCode}');
      log('ProfileService: Upload API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          log('ProfileService: Upload successful (status code check).');
          return true;
      } else {
         String errorMessage = 'Failed to upload profile photo';
          try {
             final errorJson = jsonDecode(response.body);
             errorMessage = errorJson['message'] ?? '$errorMessage (Status: ${response.statusCode})';
          } catch (_) {
             errorMessage = '$errorMessage (Status: ${response.statusCode})';
          }
         throw Exception(errorMessage);
      }
    } on TimeoutException {
       log('ProfileService: Upload request timed out.');
       throw Exception('Image upload timed out. Please try again.');
    } catch (e) {
       log('ProfileService: Error uploading profile photo: $e');
       rethrow;
    }
  }

  Future<String> getProfilePhotoUrl(String userId) async {
     final String endpointTemplate = 'api/v1/user/profile/profile-picture/$userId';
     log('ProfileService: Fetching profile photo URL for user ID: $userId from $endpointTemplate');

     try {
        final response = await super.get(endpointTemplate.replaceFirst('{user_id}', userId));

        log('ProfileService: Get Photo URL API Response Status Code: ${response.statusCode}');
        log('ProfileService: Get Photo URL API Response Body: ${response.body}');

        if (response.statusCode == 200) {
           final responseData = jsonDecode(response.body);
           final imageUrl = responseData['profilePicture'] as String?;

           if (imageUrl != null && imageUrl.isNotEmpty) {
              log('ProfileService: Fetched photo URL successfully: $imageUrl');
              return imageUrl;
           } else {
              log('ProfileService: Photo URL key "profilePicture" not found or empty in response.');
              throw Exception("Profile picture URL not found after update.");
           }
        } else {
           throw Exception("Failed to fetch profile picture URL (Status: ${response.statusCode})");
        }
     } catch (e) {
        log('ProfileService: Error fetching profile photo URL: $e');
        rethrow;
     }
  }

  Future<bool> deleteProfilePhoto() async {
    const String endpoint = 'api/v1/user/profile/profile-picture';
    log('ProfileService: Deleting profile photo via $endpoint');

    try {
      final response = await super.delete(endpoint, null);

      log('ProfileService: Delete Photo API Response Status Code: ${response.statusCode}');
      log('ProfileService: Delete Photo API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Profile photo deleted successfully.');
        return true;
      } else {
        String errorMessage = 'Failed to delete profile photo';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? '$errorMessage (Status: ${response.statusCode})';
        } catch (_) {
          errorMessage = '$errorMessage (Status: ${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error deleting profile photo: $e');
      rethrow;
    }
  }

  Future<bool> updateCoverPhoto(XFile imageFile) async {
    const String endpoint = 'api/v1/user/profile/cover-photo';
    final Uri uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    final String? token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    log('ProfileService: Uploading cover photo: ${imageFile.path} to $uri');

    try {
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      String? mimeType = lookupMimeType(imageFile.path);
      MediaType? contentType;
      if (mimeType != null) {
        final parts = mimeType.split('/');
        if (parts.length == 2) {
           contentType = MediaType(parts[0], parts[1]);
        }
      }

      request.files.add(await http.MultipartFile.fromPath(
         'coverPhoto',
         imageFile.path,
         contentType: contentType,
      ));

      log('ProfileService: Sending cover photo multipart request...');
      var streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      var response = await http.Response.fromStream(streamedResponse);

      log('ProfileService: Upload Cover API Response Status Code: ${response.statusCode}');
      log('ProfileService: Upload Cover API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          log('ProfileService: Cover photo upload successful (status code check).');
          return true;
      } else {
         String errorMessage = 'Failed to upload cover photo';
          try {
             final errorJson = jsonDecode(response.body);
             errorMessage = errorJson['message'] ?? '$errorMessage (Status: ${response.statusCode})';
          } catch (_) {
             errorMessage = '$errorMessage (Status: ${response.statusCode})';
          }
         throw Exception(errorMessage);
      }
    } on TimeoutException {
       log('ProfileService: Cover photo upload request timed out.');
       throw Exception('Cover photo upload timed out. Please try again.');
    } catch (e) {
       log('ProfileService: Error uploading cover photo: $e');
       rethrow;
    }
  }

  Future<String> getCoverPhotoUrl(String userId) async {
     final String endpointTemplate = 'api/v1/user/profile/cover-photo/$userId';
     log('ProfileService: Fetching cover photo URL for user ID: $userId from $endpointTemplate');

     try {
        final response = await get(endpointTemplate.replaceFirst('{user_id}', userId));

        log('ProfileService: Get Cover URL API Response Status Code: ${response.statusCode}');
        log('ProfileService: Get Cover URL API Response Body: ${response.body}');

        if (response.statusCode == 200) {
           final responseData = jsonDecode(response.body);
           final imageUrl = responseData['coverPhoto'] as String?; 

           if (imageUrl != null && imageUrl.isNotEmpty) {
              log('ProfileService: Fetched cover photo URL successfully: $imageUrl');
              return imageUrl;
           } else {
              log('ProfileService: Cover photo URL key not found or empty in response.');
              return "";
           }
        } else {
           log('ProfileService: Failed to fetch cover photo URL (Status: ${response.statusCode})');
           return "";
        }
     } catch (e) {
        log('ProfileService: Error fetching cover photo URL: $e');
        rethrow;
     }
  }

  Future<bool> deleteCoverPhoto() async {
    const String endpoint = 'api/v1/user/profile/cover-photo';
    log('ProfileService: Deleting cover photo via $endpoint');

    try {
      final response = await super.delete(endpoint, null);

      log('ProfileService: Delete Cover Photo API Response Status Code: ${response.statusCode}');
      log('ProfileService: Delete Cover Photo API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Cover photo deleted successfully.');
        return true;
      } else {
        String errorMessage = 'Failed to delete cover photo';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? '$errorMessage (Status: ${response.statusCode})';
        } catch (_) {
          errorMessage = '$errorMessage (Status: ${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error deleting cover photo: $e');
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

  Future<bool> addPosition(PositionModel position) async {
     final String userId = InternalEndPoints.userId;
     if (userId.isEmpty) {
       throw Exception("User ID not available. Please log in again.");
     }
     const String positionEndpoint = 'api/v1/user/add-work-experience'; 
     log('ProfileService: Adding position for user ID: $userId');
     log('ProfileService: Position data to send: ${jsonEncode(position.toJson())}');
     try {
       final response = await post(
         positionEndpoint,
         body: position.toJson(), 

       );
       log('ProfileService: addPosition API Response Status Code: ${response.statusCode}');
       log('ProfileService: addPosition API Response Body: ${response.body}');

       if (response.statusCode == 200 || response.statusCode == 201) {
         log('ProfileService: Position added successfully.');
         return true;
       } else {
         log('ProfileService: Add Position Error: Status Code ${response.statusCode}, Body: ${response.body}');
         String errorMessage = 'Failed to add position (Status code: ${response.statusCode})';
         try {
            final errorJson = jsonDecode(response.body);
            errorMessage = errorJson['message'] ?? errorMessage;
         } catch (_) {}
         throw Exception(errorMessage);
       }
     } catch (e) {
       log('ProfileService: Error adding position: $e');
       rethrow;
     }
   }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});