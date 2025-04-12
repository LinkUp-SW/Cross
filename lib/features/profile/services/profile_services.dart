import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/profile/model/education_model.dart';

class ProfileService extends BaseService {

  Future<bool> addEducation(EducationModel education) async {
    try {
      // *** IMPORTANT: Replace '/profile/education' with your actual API endpoint path ***
      // This relative path will be appended to ExternalEndPoints.baseUrl by BaseService
      const String educationEndpoint = '/profile/education'; // <-- REPLACE THIS

      // Call the 'post' method inherited from BaseService
      final response = await post(
        educationEndpoint,
        body: education.toJson(), // Pass the JSON map from the model
      );

      // Check for successful HTTP status codes (e.g., 200 OK, 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Education added successfully via API.');
        return true; // Indicate success
      } else {
        // Handle API errors (log, potentially parse error message from body)
        print('API Error: Failed to add education. Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');
        // You might want to throw a more specific exception here
        // based on the response body or status code
        return false; // Indicate failure
      }
    } catch (e) {
      // Handle network errors or exceptions during the API call
      print('Network/Service Error adding education: $e');
      // Re-throw or handle as appropriate for your error handling strategy
      // throw Exception('Could not connect to add education: $e');
      return false; // Indicate failure
    }
  }

  // --- Other ProfileService Methods ---
  // Add methods here for fetching profile data, updating intro,
  // uploading pictures, managing experience, skills, etc.
  // Example:
  // Future<ProfileModel> fetchProfileData(String userId) async { ... }
  // Future<bool> updateProfileData(ProfileModel profileData) async { ... }

}

// --- Riverpod Provider for ProfileService ---
// This makes the ProfileService available for injection into ViewModels
final profileServiceProvider = Provider<ProfileService>((ref) {
  // Since ProfileService extends BaseService, it inherits its methods.
  // If BaseService itself had dependencies provided by Riverpod, you might
  // watch them here, but typically you just instantiate ProfileService.
  return ProfileService();
});