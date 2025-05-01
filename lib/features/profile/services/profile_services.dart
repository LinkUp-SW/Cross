import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/profile/model/contact_info_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/features/profile/model/position_model.dart'; 
import 'package:link_up/features/profile/model/about_model.dart';
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
Future<AboutModel> getUserAboutAndSkills(String userId) async {
    const String endpointTemplate = ExternalEndPoints.userProfileAbout;
    log('ProfileService: Fetching about and skills for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      log('ProfileService: getUserAboutAndSkills API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        log('ProfileService: Fetched About/Skills JSON: ${jsonData.toString()}');
        return AboutModel.fromJson(jsonData);
      } else {
        log('ProfileService: getUserAboutAndSkills API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        if (response.statusCode == 404) {
           log('ProfileService: About section not found for user $userId, returning default.');
           return const AboutModel(about: '', skills: []); // Return default if not found
        }
        throw Exception('Failed to load about section (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserAboutAndSkills: $e');
      return const AboutModel(about: '', skills: []); // Return default on other errors
    }
  }

   Future<bool> updateOrAddUserAbout({
      required String userId, // Keep userId for logging, but not for the path
      required String aboutText,
      required bool isCreating // Flag to determine POST or PUT
  }) async {
    // *** CORRECTED ENDPOINT PATH for POST/PUT ***
    const String endpoint = 'api/v1/user/profile/about'; // Use the exact path from docs
    final httpMethod = isCreating ? 'POST' : 'PUT';
    log('ProfileService: ${isCreating ? 'Adding' : 'Updating'} about for user ID: $userId via $httpMethod to endpoint: $endpoint');

    final Map<String, dynamic> requestBody = {'about': aboutText};
    log('ProfileService: Sending $httpMethod request body: ${jsonEncode(requestBody)}');
    try {
      final response = isCreating
          ? await super.post(endpoint, body: requestBody) // Use super.post
          : await super.put(endpoint, requestBody); // Use super.put
      log('ProfileService: updateOrAddUserAbout ($httpMethod) API Response Status Code: ${response.statusCode}');
      log('ProfileService: updateOrAddUserAbout ($httpMethod) API Response Body: ${response.body}'); // Log the full response body

      // Check status code AFTER logging
      // POST often returns 201 (Created), PUT often returns 200 (OK) or 204 (No Content)
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          log('ProfileService: About ${isCreating ? 'add' : 'update'} successful (status code check).');
          return true;
      } else {
          // Log failure before returning false or throwing
          log('ProfileService: About ${isCreating ? 'add' : 'update'} failed (status code ${response.statusCode}).');
          // Optionally throw an exception with more details from response.body if needed by ViewModel
          // throw Exception('Failed to ${isCreating ? 'add' : 'update'} about: ${response.body}');
          return false; // Indicate failure for non-success codes
      }
    } catch(e, stackTrace) {
      log('ProfileService: Error ${isCreating ? 'adding' : 'updating'} about: $e\nStackTrace: $stackTrace');
      rethrow; // Rethrow to be caught by ViewModel
    }
  }
  Future<List<PositionModel>> getUserExperience(String userId) async {
     const String endpointTemplate = ExternalEndPoints.getUserExperience; //'api/v1/user/profile/experience/:user_id';
     log('ProfileService: Fetching experience for user ID: $userId');
     try {
       final response = await super.get(
         endpointTemplate,
         routeParameters: {'user_id': userId},
       );
       log('ProfileService: getUserExperience API Response Status Code: ${response.statusCode}');
       if (response.statusCode == 200) {
         final Map<String, dynamic> jsonData = jsonDecode(response.body);
         final List<dynamic> experienceJsonList = jsonData['work_experience'] as List? ?? [];
         final List<PositionModel> experiences = experienceJsonList
             .map((expJson) => expJson is Map<String, dynamic> ? PositionModel.fromJson(expJson) : null)
             .whereType<PositionModel>()
             .toList();
         return experiences;
       } else {
         log('ProfileService: getUserExperience API Error: Status Code ${response.statusCode}, Body: ${response.body}');
         throw Exception('Failed to load experience (Status code: ${response.statusCode})');
       }
     } catch (e) {
       log('ProfileService: Error in getUserExperience: $e');
       rethrow;
     }
   } 
  Future<List<EducationModel>> getUserEducation(String userId) async {
   const String endpointTemplate = ExternalEndPoints.getUserEducation; 
   log('ProfileService: Fetching education for user ID: $userId');
   try {
     final response = await super.get( 
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

  Future<String?> getCurrentResumeUrl(String userId) async {
    final String endpointTemplate = 'api/v1/user/profile/resume/:user_id';
    log('ProfileService: Getting resume URL for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      log('ProfileService: getCurrentResumeUrl API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final resumeUrl = jsonData['resume'] as String?;
        log('ProfileService: Fetched resume URL: $resumeUrl');
        return resumeUrl; 
      } else if (response.statusCode == 404) {
         log('ProfileService: No resume found for user $userId (404).');
         return null; 
      } else {
        log('ProfileService: getCurrentResumeUrl API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('ProfileService: Error in getCurrentResumeUrl: $e');
      return null; 
    }
  }


   Future<String> uploadOrUpdateResume(File resumeFile, bool isUpdating) async {
    const String endpoint = 'api/v1/user/profile/resume';
    final Uri uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    final String? token = await getToken();
    final String httpMethod = isUpdating ? 'PUT' : 'POST';

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    // --- Pre-Request Logging ---
    log('--- Preparing Resume Upload ---');
    log('ProfileService: Target URL: $uri');
    log('ProfileService: HTTP Method: $httpMethod');
    log('ProfileService: Auth Token Present: ${token.isNotEmpty}'); // Log token presence, not value
    log('ProfileService: File Path: ${resumeFile.path}');
    try {
      final fileSize = await resumeFile.length();
      log('ProfileService: File Size: $fileSize bytes');
    } catch (e) {
      log('ProfileService: Error getting file size: $e');
    }
    // --- End Pre-Request Logging ---

    try {
      var request = http.MultipartRequest(httpMethod, uri);

      // Add Headers (Log them *after* adding)
      request.headers['Authorization'] = 'Bearer $token';
      log('ProfileService: Request Headers: ${request.headers}');


      MediaType contentType = MediaType('application', 'pdf');
      log('ProfileService: Explicit Content-Type: ${contentType.toString()}');

      // Prepare the file part
      final filePart = await http.MultipartFile.fromPath(
         'resume', // Field name confirmed from docs
         resumeFile.path,
         contentType: contentType,
      );
      request.files.add(filePart);
      log('ProfileService: Added file part. Field: ${filePart.field}, Filename: ${filePart.filename}, Length: ${filePart.length}, ContentType: ${filePart.contentType}');


      log('ProfileService: Sending resume multipart request ($httpMethod)...');
      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));

      // --- Post-Response Logging ---
      log('--- Received Resume Upload Response ---');
      log('ProfileService: Response Status Code: ${streamedResponse.statusCode}');
      log('ProfileService: Response Reason Phrase: ${streamedResponse.reasonPhrase}');
      log('ProfileService: Response Headers: ${jsonEncode(streamedResponse.headers)}'); // Encode headers for clarity

      var response = await http.Response.fromStream(streamedResponse);
      log('ProfileService: Response Body: ${response.body}');
      // --- End Post-Response Logging ---


      // Check status code *after* logging response details
      if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final newUrl = responseData['resume'] as String?;
          if (newUrl != null && newUrl.isNotEmpty) {
              log('ProfileService: Resume ${isUpdating ? 'update' : 'upload'} successful. New URL: $newUrl');
              return newUrl;
          } else {
              // Log before throwing
              log('ProfileService: Error: Resume ${isUpdating ? 'update' : 'upload'} successful (status ${response.statusCode}), but URL not found in response body: ${response.body}');
              throw Exception('Resume ${isUpdating ? 'update' : 'upload'} successful, but URL not found in response.');
          }
      } else {
         // Log before throwing specific error
         log('ProfileService: Error: Request failed with status ${response.statusCode}. Body: ${response.body}');
         String errorMessage = 'Failed to ${isUpdating ? 'update' : 'upload'} resume';
          try {
             // Try to parse backend error only if body isn't empty
             if (response.body.isNotEmpty && response.body != '{}') {
                 final errorJson = jsonDecode(response.body);
                 errorMessage = errorJson['message'] ?? '$errorMessage (Status: ${response.statusCode})';
             } else {
                 errorMessage = '$errorMessage (Status: ${response.statusCode}) - Empty response body';
             }
          } catch (e) {
             // Catch JSON parsing error if body is not valid JSON
             log('ProfileService: Error parsing error response body: $e');
             errorMessage = '$errorMessage (Status: ${response.statusCode}) - Non-JSON or empty response body';
          }
         throw Exception(errorMessage);
      }
    } on TimeoutException catch(e, s) { // Catch specific exceptions for better logging
       log('ProfileService: Resume upload/update request timed out.', error: e, stackTrace: s);
       throw Exception('Resume upload timed out. Please try again.');
    } catch (e, s) {
       log('ProfileService: Error ${isUpdating ? 'updating' : 'uploading'} resume: $e', error: e, stackTrace: s);
       rethrow; // Rethrow the original exception
    }
  }



  Future<bool> deleteResume() async {
    const String endpoint = 'api/v1/user/profile/resume';
    log('ProfileService: Deleting resume via DELETE $endpoint');

    try {
      final response = await super.delete(endpoint, null); 

      log('ProfileService: Delete Resume API Response Status Code: ${response.statusCode}');
      log('ProfileService: Delete Resume API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Resume deleted successfully.');
        return true;
      } else {
        log('ProfileService: Failed to delete resume. Status Code: ${response.statusCode}');

        return false; 
      }
    } catch (e) {
      log('ProfileService: Error deleting resume: $e');
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