import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/profile/model/about_model.dart';
import 'package:link_up/features/profile/model/contact_info_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/model/blocked_user_model.dart';
import 'package:mime/mime.dart';

class ProfileService extends BaseService {
  // --- Core Profile ---

  Future<UserProfile> getUserProfile(String userId) async {
    const String endpointTemplate = 'api/v1/user/profile/bio/:user_id';
    log('ProfileService: Fetching profile for UserProfile model, user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return UserProfile.fromJson(jsonData);
      } else {
        log('ProfileService: getUserProfile API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load profile (Status code: ${response.statusCode})');
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
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        log('ProfileService: fetchFullUserProfileJson API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load profile JSON (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error fetching full profile data JSON: $e');
      rethrow;
    }
  }

  // --- About & Skills ---

  Future<AboutModel> getUserAboutAndSkills(String userId) async {
    const String endpointTemplate = ExternalEndPoints.userProfileAbout;
    log('ProfileService: Fetching about and skills for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return AboutModel.fromJson(jsonData);
      } else {
        log('ProfileService: getUserAboutAndSkills API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        if (response.statusCode == 404) {
          log('ProfileService: About section not found for user $userId, returning default.');
          return const AboutModel(about: '', skills: []);
        }
        throw Exception(
            'Failed to load about section (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserAboutAndSkills: $e');
      return const AboutModel(about: '', skills: []);
    }
  }

  Future<bool> updateOrAddUserAbout(
      {required String userId,
      required String aboutText,
      required bool isCreating}) async {
    const String endpoint = 'api/v1/user/profile/about';
    final httpMethod = isCreating ? 'POST' : 'PUT';
    log('ProfileService: ${isCreating ? 'Adding' : 'Updating'} about for user ID: $userId via $httpMethod to endpoint: $endpoint');

    final Map<String, dynamic> requestBody = {'about': aboutText};
    try {
      final response = isCreating
          ? await super.post(endpoint, body: requestBody)
          : await super.put(endpoint, body: requestBody);
      log('ProfileService: updateOrAddUserAbout ($httpMethod) API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        log('ProfileService: About ${isCreating ? 'add' : 'update'} successful.');
        return true;
      } else {
        log('ProfileService: About ${isCreating ? 'add' : 'update'} failed (status code ${response.statusCode}). Body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      log('ProfileService: Error ${isCreating ? 'adding' : 'updating'} about: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<SkillModel>> getUserSkills(String userId) async {
    final String endpointTemplate = 'api/v1/user/profile/skills/:user_id';
    log('ProfileService: Fetching skills for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> skillsJsonList = jsonData['skills'] as List? ?? [];
        final List<SkillModel> skills = skillsJsonList
            .map((skillJson) => skillJson is Map<String, dynamic>
                ? SkillModel.fromJson(skillJson)
                : null)
            .whereType<SkillModel>()
            .toList();
        log('ProfileService: Fetched ${skills.length} skills.');
        return skills;
      } else if (response.statusCode == 404) {
        log('ProfileService: No skills found for user $userId (404).');
        return [];
      } else {
        log('ProfileService: getUserSkills API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load skills (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserSkills: $e');
      rethrow;
    }
  }

  Future<bool> addSkill(SkillModel skill) async {
    const String endpoint = 'api/v1/user/add-skill';
    log('ProfileService: Adding skill: ${skill.name}');
    try {
      final response = await post(endpoint, body: skill.toJson());
      log('ProfileService: addSkill API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('ProfileService: Skill added successfully.');
        return true;
      } else {
        log('ProfileService: Add Skill Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to add skill (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error adding skill: $e');
      rethrow;
    }
  }

  Future<bool> updateSkill(String skillId, SkillModel skill) async {
    final String endpointTemplate = 'api/v1/user/update-skill/:skillId';
    final String endpoint = endpointTemplate.replaceFirst(':skillId', skillId);
    log('ProfileService: Updating skill ID: $skillId with name: ${skill.name}');
    try {
      final response = await put(endpoint, body: skill.toJson());
      log('ProfileService: updateSkill API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Skill updated successfully.');
        return true;
      } else {
        log('ProfileService: Update Skill Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to update skill (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error updating skill: $e');
      rethrow;
    }
  }

  Future<bool> deleteSkill(String skillId) async {
    final String endpointTemplate = 'api/v1/user/delete-skill/:skillId';
    final String endpoint = endpointTemplate.replaceFirst(':skillId', skillId);
    log('ProfileService: Deleting skill ID: $skillId');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: deleteSkill API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Skill deleted successfully.');
        return true;
      } else {
        log('ProfileService: Delete Skill Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to delete skill (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error deleting skill: $e');
      rethrow;
    }
  }

  // --- Experience ---

  Future<List<PositionModel>> getUserExperience(String userId) async {
    const String endpointTemplate = ExternalEndPoints.getUserExperience;
    log('ProfileService: Fetching experience for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> experienceJsonList =
            jsonData['work_experience'] as List? ?? [];
        final List<PositionModel> experiences = experienceJsonList
            .map((expJson) => expJson is Map<String, dynamic>
                ? PositionModel.fromJson(expJson)
                : null)
            .whereType<PositionModel>()
            .toList();
        return experiences;
      } else {
        log('ProfileService: getUserExperience API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load experience (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserExperience: $e');
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
    try {
      final response = await post(
        positionEndpoint,
        body: position.toJson(),
      );
      log('ProfileService: addPosition API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('ProfileService: Position added successfully.');
        return true;
      } else {
        log('ProfileService: Add Position Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to add position (Status code: ${response.statusCode})';
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

  Future<bool> updateExperience(
      String experienceId, PositionModel position) async {
    final String endpointTemplate =
        'api/v1/user/update-work-experience/:experienceId';
    final String endpoint =
        endpointTemplate.replaceFirst(':experienceId', experienceId);

    log('ProfileService: Updating experience ID: $experienceId');
    log('ProfileService: Position data to send: ${jsonEncode(position.toJson())}');

    try {
      final response = await put(endpoint, body: position.toJson());

      log('ProfileService: updateExperience API Response Status Code: ${response.statusCode}');
      log('ProfileService: updateExperience API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Experience updated successfully.');
        return true;
      } else {
        log('ProfileService: Update Experience Error: Status Code ${response.statusCode}, Body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('ProfileService: Error updating experience: $e');
      rethrow;
    }
  }

  Future<bool> deleteExperience(String expID) async {
    final String endpointTemplate =
        'api/v1/user/delete-work-experience/:experienceId';
    final String endpoint =
        endpointTemplate.replaceFirst(':experienceId', expID);
    log('ProfileService: Deleting experience ID: $expID');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: deleteExperience API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: experience deleted successfully.');
        return true;
      } else {
        log('ProfileService: Delete experience Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to delete experience (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error deleting experience: $e');
      rethrow;
    }
  }

  // --- Education ---

  Future<List<EducationModel>> getUserEducation(String userId) async {
    const String endpointTemplate = ExternalEndPoints.getUserEducation;
    log('ProfileService: Fetching education for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> educationJsonList =
            jsonData['education'] as List? ?? [];
        final List<EducationModel> educations = educationJsonList
            .map((eduJson) => eduJson is Map<String, dynamic>
                ? EducationModel.fromJson(eduJson)
                : null)
            .whereType<EducationModel>()
            .toList();
        return educations;
      } else {
        log('ProfileService: getUserEducation API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load education (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserEducation: $e');
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
        throw Exception(
            'Failed to add education (Status Code: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('ProfileService: Error adding education: $e');
      rethrow;
    }
  }

  Future<bool> updateEducation(
      String educationID, EducationModel education) async {
    final String endpointTemplate = 'api/v1/user/update-education/:educationId';
    final String endpoint =
        endpointTemplate.replaceFirst(':educationId', educationID);

    log('ProfileService: Updating Education ID: $educationID');
    log('ProfileService: Education data to send: ${jsonEncode(education.toJson())}');

    try {
      final response = await put(endpoint, body: education.toJson());

      log('ProfileService: updateEducation API Response Status Code: ${response.statusCode}');
      log('ProfileService: updateEducation API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Education updated successfully.');
        return true;
      } else {
        log('ProfileService: Update Education Error: Status Code ${response.statusCode}, Body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('ProfileService: Error updating Education: $e');
      rethrow;
    }
  }

  Future<bool> deleteEducation(String eduID) async {
    final String endpointTemplate = 'api/v1/user/delete-education/:educationId';
    final String endpoint =
        endpointTemplate.replaceFirst(':educationId', eduID);
    log('ProfileService: Deleting education ID: $eduID');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: deleteEducation API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: education deleted successfully.');
        return true;
      } else {
        log('ProfileService: Delete education Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to delete education (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('ProfileService: Error deleting education: $e');
      rethrow;
    }
  }
  // --- Licenses & Certifications ---

  Future<List<LicenseModel>> getUserLicenses(String userId) async {
    const String endpointTemplate = ExternalEndPoints.getUserLicenses;
    log('ProfileService: Fetching licenses for user ID: $userId');
    try {
      final response = await super.get(
        endpointTemplate,
        routeParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> licenseJsonList =
            jsonData['licenses'] as List? ?? [];
        final List<LicenseModel> licenses = licenseJsonList
            .map((licJson) => licJson is Map<String, dynamic>
                ? LicenseModel.fromJson(licJson)
                : null)
            .whereType<LicenseModel>()
            .toList();
        return licenses;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        log('ProfileService: getUserLicenses API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load licenses (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserLicenses: $e');
      rethrow;
    }
  }

  Future<bool> addLicense(LicenseModel license) async {
    const String endpoint = ExternalEndPoints.addLicense;
    final String userId = InternalEndPoints.userId;
    if (userId.isEmpty) {
      throw Exception("User ID not available. Please log in again.");
    }
    log('ProfileService: Adding license for user ID: $userId');
    try {
      final response = await post(
        endpoint,
        body: license.toJson(),
      );
      log('ProfileService: addLicense API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        log('ProfileService: Add License Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to add license (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error adding license: $e');
      rethrow;
    }
  }

  Future<bool> updateLicense(String licenseId, LicenseModel license) async {
    final String endpointTemplate = ExternalEndPoints.updateLicense;
    final String endpoint =
        endpointTemplate.replaceFirst(':licenseId', licenseId);
    log('ProfileService: Updating license ID: $licenseId');
    try {
      final response = await put(
        endpoint,
        body: license.toJson(),
      );
      log('ProfileService: updateLicense API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        log('ProfileService: Update License Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to update license (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error updating license: $e');
      rethrow;
    }
  }

  Future<bool> deleteLicense(String licenseId) async {
    final String endpointTemplate = ExternalEndPoints.deleteLicense;
    final String endpoint =
        endpointTemplate.replaceFirst(':licenseId', licenseId);
    log('ProfileService: Deleting license ID: $licenseId');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: deleteLicense API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        log('ProfileService: Delete License Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to delete license (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error deleting license: $e');
      rethrow;
    }
  }

  // --- Contact Info ---

  Future<ContactInfoModel> getContactInfo(String userId) async {
    log('ProfileService: Getting ContactInfoModel for user ID: $userId');
    try {
      final fullProfileJson = await fetchFullUserProfileJson(userId);
      final bio = fullProfileJson['bio'] as Map<String, dynamic>?;
      final contactInfoJson = bio?['contact_info'] as Map<String, dynamic>?;

      if (contactInfoJson != null) {
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

  Future<bool> updateContactInfo(
      {required String userId,
      required ContactInfoModel updatedContactInfo,
      required Map<String, dynamic> originalBio}) async {
    const String endpoint = 'api/v1/user/update-user-profile';
    final Map<String, dynamic> updatedContactInfoJson =
        updatedContactInfo.toJson();
    final Map<String, dynamic> requestBio =
        Map<String, dynamic>.from(originalBio);
    requestBio['contact_info'] = updatedContactInfoJson;
    final Map<String, dynamic> requestBody = {'bio': requestBio};

    log('ProfileService: Updating contact info for user ID: $userId');

    try {
      final response = await put(endpoint, body: requestBody);
      log('ProfileService: updateContactInfo API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Contact info updated successfully.');
        return true;
      } else {
        log('ProfileService: Failed to update contact info. Status Code: ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to update contact info (Status code: ${response.statusCode})';
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

  // --- Resume ---

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

    log('ProfileService: Preparing Resume ${isUpdating ? 'Update' : 'Upload'}');
    log('ProfileService: Target URL: $uri');
    log('ProfileService: HTTP Method: $httpMethod');
    log('ProfileService: File Path: ${resumeFile.path}');

    try {
      var request = http.MultipartRequest(httpMethod, uri);
      request.headers['Authorization'] = 'Bearer $token';

      MediaType contentType = MediaType('application', 'pdf');

      final filePart = await http.MultipartFile.fromPath(
        'resume',
        resumeFile.path,
        contentType: contentType,
      );
      request.files.add(filePart);

      log('ProfileService: Sending resume multipart request ($httpMethod)...');
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);
      log('ProfileService: Received Resume ${isUpdating ? 'Update' : 'Upload'} Response');
      log('ProfileService: Status Code: ${response.statusCode}');
      log('ProfileService: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final newUrl = responseData['resume'] as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          log('ProfileService: Resume ${isUpdating ? 'update' : 'upload'} successful. New URL: $newUrl');
          return newUrl;
        } else {
          log('ProfileService: Error: Resume ${isUpdating ? 'update' : 'upload'} successful (status ${response.statusCode}), but URL not found in response body.');
          throw Exception(
              'Resume ${isUpdating ? 'update' : 'upload'} successful, but URL not found in response.');
        }
      } else {
        log('ProfileService: Error: Request failed with status ${response.statusCode}.');
        String errorMessage =
            'Failed to ${isUpdating ? 'update' : 'upload'} resume';
        try {
          if (response.body.isNotEmpty) {
            final errorJson = jsonDecode(response.body);
            errorMessage = errorJson['message'] ??
                '$errorMessage (Status: ${response.statusCode})';
          } else {
            errorMessage = '$errorMessage (Status: ${response.statusCode})';
          }
        } catch (e) {
          log('ProfileService: Error parsing error response body: $e');
          errorMessage =
              '$errorMessage (Status: ${response.statusCode}) - Invalid/empty response body';
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException catch (e, s) {
      log('ProfileService: Resume upload/update request timed out.',
          error: e, stackTrace: s);
      throw Exception('Resume upload timed out. Please try again.');
    } catch (e, s) {
      log('ProfileService: Error ${isUpdating ? 'updating' : 'uploading'} resume: $e',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<bool> deleteResume() async {
    const String endpoint = 'api/v1/user/profile/resume';
    log('ProfileService: Deleting resume via DELETE $endpoint');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: Delete Resume API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Resume deleted successfully.');
        return true;
      } else {
        log('ProfileService: Failed to delete resume. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      log('ProfileService: Error deleting resume: $e');
      rethrow;
    }
  }

  // --- Profile Photo ---

  Future<String> getProfilePhotoUrl(String userId) async {
    final String endpointTemplate =
        'api/v1/user/profile/profile-picture/$userId';
    log('ProfileService: Fetching profile photo URL for user ID: $userId');
    try {
      final response =
          await super.get(endpointTemplate.replaceFirst('{user_id}', userId));
      log('ProfileService: Get Profile Photo URL API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['profilePicture'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          log('ProfileService: Fetched photo URL successfully: $imageUrl');
          return imageUrl;
        } else {
          log('ProfileService: Photo URL key "profilePicture" not found or empty in response: ${response.body}');
          throw Exception("Profile picture URL not found after fetch.");
        }
      } else {
        log('ProfileService: Failed to fetch profile picture URL (Status: ${response.statusCode}), Body: ${response.body}');
        throw Exception(
            "Failed to fetch profile picture URL (Status: ${response.statusCode})");
      }
    } catch (e) {
      log('ProfileService: Error fetching profile photo URL: $e');
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

      log('ProfileService: Sending profile photo multipart request...');
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      log('ProfileService: Upload Profile Photo API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        log('ProfileService: Profile photo upload successful.');
        return true;
      } else {
        log('ProfileService: Upload Profile Photo Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage = 'Failed to upload profile photo';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ??
              '$errorMessage (Status: ${response.statusCode})';
        } catch (_) {
          errorMessage = '$errorMessage (Status: ${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      log('ProfileService: Upload profile photo request timed out.');
      throw Exception('Image upload timed out. Please try again.');
    } catch (e) {
      log('ProfileService: Error uploading profile photo: $e');
      rethrow;
    }
  }

  Future<bool> deleteProfilePhoto() async {
    const String endpoint = 'api/v1/user/profile/profile-picture';
    log('ProfileService: Deleting profile photo via $endpoint');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: Delete Profile Photo API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Profile photo deleted successfully.');
        return true;
      } else {
        log('ProfileService: Delete Profile Photo Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage = 'Failed to delete profile photo';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ??
              '$errorMessage (Status: ${response.statusCode})';
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

  // --- Cover Photo ---

  Future<String> getCoverPhotoUrl(String userId) async {
    final String endpointTemplate = 'api/v1/user/profile/cover-photo/$userId';
    log('ProfileService: Fetching cover photo URL for user ID: $userId');
    try {
      final response =
          await get(endpointTemplate.replaceFirst('{user_id}', userId));
      log('ProfileService: Get Cover Photo URL API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['coverPhoto'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          log('ProfileService: Fetched cover photo URL successfully: $imageUrl');
          return imageUrl;
        } else {
          log('ProfileService: Cover photo URL key not found or empty in response: ${response.body}');
          return "";
        }
      } else if (response.statusCode == 404) {
        log('ProfileService: Cover photo not found for user $userId (404).');
        return "";
      } else {
        log('ProfileService: Failed to fetch cover photo URL (Status: ${response.statusCode}), Body: ${response.body}');
        return "";
      }
    } catch (e) {
      log('ProfileService: Error fetching cover photo URL: $e');
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
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 45));
      var response = await http.Response.fromStream(streamedResponse);
      log('ProfileService: Upload Cover Photo API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        log('ProfileService: Cover photo upload successful.');
        return true;
      } else {
        log('ProfileService: Upload Cover Photo Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage = 'Failed to upload cover photo';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ??
              '$errorMessage (Status: ${response.statusCode})';
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

  Future<bool> deleteCoverPhoto() async {
    const String endpoint = 'api/v1/user/profile/cover-photo';
    log('ProfileService: Deleting cover photo via $endpoint');
    try {
      final response = await super.delete(endpoint, null);
      log('ProfileService: Delete Cover Photo API Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: Cover photo deleted successfully.');
        return true;
      } else {
        log('ProfileService: Delete Cover Photo Error: Status Code ${response.statusCode}, Body: ${response.body}');
        String errorMessage = 'Failed to delete cover photo';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ??
              '$errorMessage (Status: ${response.statusCode})';
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

  // --- Skill Linking ---

  Future<Map<String, List<LinkableItem>>> getUserSections() async {
    const String endpoint = 'api/v1/user/get-user-sections';
    log('ProfileService: Fetching user sections for skill linking');
    try {
      final response = await super.get(endpoint);
      log('ProfileService: getUserSections API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> experiencesJson =
            jsonData['experiences'] as List? ?? [];
        final List<dynamic> educationsJson =
            jsonData['educations'] as List? ?? [];
        final List<dynamic> licensesJson = jsonData['licenses'] as List? ?? [];

        final List<LinkableItem> experiences = experiencesJson
            .map((exp) {
              if (exp is Map<String, dynamic> &&
                  exp['_id'] != null &&
                  exp['name'] != null) {
                return LinkableItem(
                  id: exp['_id'] as String,
                  title: exp['name'] as String,
                  subtitle: 'Experience',
                  type: 'experience',
                );
              }
              return null;
            })
            .whereType<LinkableItem>()
            .toList();

        final List<LinkableItem> educations = educationsJson
            .map((edu) {
              if (edu is Map<String, dynamic> &&
                  edu['_id'] != null &&
                  edu['name'] != null) {
                return LinkableItem(
                  id: edu['_id'] as String,
                  title: 'Education',
                  subtitle: edu['name'] as String,
                  type: 'education',
                );
              }
              return null;
            })
            .whereType<LinkableItem>()
            .toList();

        final List<LinkableItem> licenses = licensesJson
            .map((lic) {
              if (lic is Map<String, dynamic> &&
                  lic['_id'] != null &&
                  lic['name'] != null) {
                return LinkableItem(
                  id: lic['_id'] as String,
                  title: lic['name'] as String,
                  subtitle: 'License/Certification',
                  type: 'license',
                );
              }
              return null;
            })
            .whereType<LinkableItem>()
            .toList();

        log('ProfileService: Parsed ${experiences.length} experiences, ${educations.length} educations, ${licenses.length} licenses for linking.');
        return {
          'experience': experiences,
          'education': educations,
          'license': licenses,
        };
      } else {
        log('ProfileService: getUserSections API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load sections (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getUserSections: $e');
      rethrow;
    }
  }

//block
  Future<bool> blockUser(String userIdToBlock) async {
    final String endpointTemplate = 'api/v1/user/block/:user_id';
    final String endpointPath =
        endpointTemplate.replaceFirst(':user_id', userIdToBlock);
    final Uri uri = Uri.parse(
        '${ExternalEndPoints.baseUrl}$endpointPath'); // Construct full URL

    log('ProfileService: Attempting to block user ID: $userIdToBlock via POST $uri');

    final String? token = await getToken();
    if (token == null || token.isEmpty) {
      log('ProfileService: Block failed - Auth token not found.');
      throw Exception("Authentication token not found.");
    }

    try {
      final http.Response response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 15));

      log('ProfileService: Block User API Response Status Code: ${response.statusCode}');
      log('ProfileService: Block User API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('ProfileService: User $userIdToBlock blocked successfully.');
        return true;
      } else if (response.statusCode == 400 &&
          response.body.contains('User is already blocked')) {
        log('ProfileService: User $userIdToBlock is already blocked.');
        return true;
      } else {
        log('ProfileService: Block failed for user $userIdToBlock. Status Code: ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to block user (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException catch (e) {
      log('ProfileService: Block request timed out for user $userIdToBlock: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      log('ProfileService: Error sending block request for $userIdToBlock: $e');
      rethrow;
    }
  }

  Future<List<BlockedUser>> getBlockedUsers() async {
    const String endpoint = 'api/v1/user/manage-by-blocked-list/blocked';
    log('ProfileService: Fetching blocked users list from $endpoint');

    try {
      final response = await super.get(endpoint);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> blockedListJson =
            jsonData['blocked_list'] as List? ?? [];
        final List<BlockedUser> blockedUsers = blockedListJson
            .map((userJson) => userJson is Map<String, dynamic>
                ? BlockedUser.fromJson(userJson)
                : null)
            .whereType<BlockedUser>()
            .toList();

        log('ProfileService: Fetched ${blockedUsers.length} blocked users.');
        return blockedUsers;
      } else if (response.statusCode == 404) {
        log('ProfileService: No blocked users found (404). Returning empty list.');
        return [];
      } else {
        log('ProfileService: getBlockedUsers API Error: Status Code ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load blocked users list (Status code: ${response.statusCode})');
      }
    } catch (e) {
      log('ProfileService: Error in getBlockedUsers: $e');
      rethrow;
    }
  }

  Future<bool> unblockUser(String userIdToUnblock, String password) async {
    final String endpointTemplate =
        'api/v1/user/manage-by-blocked-list/unblock/:user_id';
    final String endpointPath =
        endpointTemplate.replaceFirst(':user_id', userIdToUnblock);
    final Uri uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpointPath');

    log('ProfileService: Attempting to unblock user ID: $userIdToUnblock via DELETE $uri');

    final Map<String, dynamic> requestBodyMap = {
      "password": password,
    };
    final String requestBodyJson = jsonEncode(requestBodyMap);

    final String? token = await getToken();
    if (token == null || token.isEmpty) {
      log('ProfileService: Unblock failed - Auth token not found.');
      throw Exception("Authentication token not found.");
    }

    try {
      final http.Response response = await http
          .delete(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: requestBodyJson,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('ProfileService: User $userIdToUnblock unblocked successfully.');
        return true;
      } else if (response.statusCode == 400) {
        log('ProfileService: Unblock failed for user $userIdToUnblock (400 Bad Request): Body: ${response.body}');
        String errorMessage = 'Bad request during unblock.';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        log('ProfileService: Unblock failed for user $userIdToUnblock (401 Unauthorized): Incorrect password likely. Body: ${response.body}');
        String errorMessage = 'Incorrect password.';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      } else {
        log('ProfileService: Unblock failed for user $userIdToUnblock. Status Code: ${response.statusCode}, Body: ${response.body}');
        String errorMessage =
            'Failed to unblock user (Status code: ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException catch (e) {
      log('ProfileService: Unblock request timed out for user $userIdToUnblock: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      log('ProfileService: Error sending unblock request for $userIdToUnblock: $e');

      rethrow;
    }
  }

  Future<Map<String, dynamic>> unfollow(String userId) async {
    try {
      final response =
          await super.delete(ExternalEndPoints.unfollow, {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to unfollow ${response.statusCode}');
    } catch (e) {
      log("Error unfollowing user with user id: $userId, error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> follow(String userId) async {
    try {
      final response = await super
          .post(ExternalEndPoints.follow, routeParameters: {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to follow ${response.statusCode}');
    } catch (e) {
      log("Error following user with user id: $userId, error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendConnectionRequest(
    String userId, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await super.post(ExternalEndPoints.connect,
          body: body, routeParameters: {'user_id': userId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          'Failed to send connection request: ${response.body} , status code: ${response.statusCode}');
    } catch (e) {
      log("Error sending connection request to user with id: $userId, error: $e");
      rethrow;
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});
