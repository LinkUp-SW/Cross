import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'dart:developer';
class ApiChatService {
  @override
  Future<bool> blockUser(String userid) async {
    // Call your backend API here using `http` or `dio`
    final baseService = BaseService();
    final response = await baseService.get(ExternalEndPoints.blockmessaging, routeParameters: {
      "userId": userid,
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      print("error: ${response.statusCode}");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchChats() async {
    try {
      final baseService = BaseService();
      final response = await baseService.get(ExternalEndPoints.fetchChats);

      if (response.statusCode == 200) {
        log(response.body);
        return jsonDecode(response.body);
      } else {
        log("error: ${response.body}");
        throw Exception("Failed to fetch chats");
      }
    } catch (e) {
      log("error: $e");
      rethrow;
    }
  }
}

final chatServiceProvider = Provider<ApiChatService>((ref) {
  return ApiChatService();
});
