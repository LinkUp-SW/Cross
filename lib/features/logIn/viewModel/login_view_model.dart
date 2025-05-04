import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/logIn/model/login_model.dart';
import 'package:link_up/features/logIn/services/login_service.dart';
import 'package:link_up/features/logIn/state/login_state.dart';
import 'package:link_up/features/chat/services/global_socket_service.dart';
import 'package:link_up/features/notifications/services/local_push_notification.dart';

final logInServiceProvider = Provider((ref) => LogInService());

final logInProvider = StateNotifierProvider<LogInNotifier, LogInState>((ref) {
  final service = ref.watch(logInServiceProvider);
  return LogInNotifier(service);
});

class LogInNotifier extends StateNotifier<LogInState> {
  final LogInService _logInService;

  LogInNotifier(this._logInService) : super(const LogInInitialState());
  Future<void> logIn(String email, String password, WidgetRef ref) async {
    state = const LogInLoadingState(); // Show loading indicator
    try {
      final success =
          await _logInService.logIn(LogInModel(email: email, password: password)).catchError((error, stackTrace) {
        state = const LogInErrorState("Invalid credentials");
        throw error;
      });
      if (success.isNotEmpty) {
        InternalEndPoints.email = email;
        InternalEndPoints.userId = success['user']['id'];
        InternalEndPoints.profileUrl = await getProfileUrl(InternalEndPoints.userId);

        // After successful login and token storage
        await getToken();

        // Initialize the global socket
        final socketService = ref.read(globalSocketServiceProvider);
        socketService.initialize();
        /* final localpushService = LocalPushNotificationService();
        await localpushService.initialize(); */

        state = LogInSuccessState(isAdmin: success['user']['isAdmin'] ?? true);
      }
    } catch (e) {
      state = const LogInErrorState('There was an error logging in. Please try again.');
    }
  }

  Future<void> getUserData() async {
    final response = await _logInService.getUserData();
    if (response.isNotEmpty) {
      InternalEndPoints.firstName = response['bio']['first_name'];
      InternalEndPoints.lastName = response['bio']['last_name'];
      InternalEndPoints.profileImage = response['bio']['profile_photo'];
      log(InternalEndPoints.firstName);
      log(InternalEndPoints.lastName);
      log(InternalEndPoints.profileImage);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<String> getProfileUrl(String userId) async {
    final BaseService baseService = BaseService();
    final response =
        await baseService.get('api/v1/user/profile/profile-picture/:user_id', routeParameters: {'user_id': userId});
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['profilePicture'];
    } else {
      return 'https://i.pravatar.cc/300?img=52';
    }
  }

  Future<void> checkStoredCredentials(WidgetRef ref) async {
    // Check if email and password are stored in secure storage
    if (await checkForRememberMe()) {
      // Retrieve stored credentials
      final credentials = await returncred();

      // Automatically log in if credentials are found

      logIn(credentials[0], credentials[1], ref);
    }
  }
}
