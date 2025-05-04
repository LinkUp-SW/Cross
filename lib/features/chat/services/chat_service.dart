import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';

class ApiChatService {
  final BaseService _baseService = BaseService();

  Future<bool> blockUser(String userid) async {
    try {
      final response = await _baseService.put(
        ExternalEndPoints.blockmessaging,body:{},
        routeParameters: {'user_id': userid},
      );

      if (response.statusCode == 200) {
        log("User blocked successfully: $userid");
        return true;
      }
      log("Failed to block user: ${response.statusCode}");
      return false;
    } catch (e) {
      log("Error blocking user: $e");
      return false;
    }
  }

  Future<bool> deleteChat(String conversationId) async {
    try {
      final response = await _baseService.delete(
        ExternalEndPoints.deleteChat,
        {'conversationId': conversationId},
      );

      if (response.statusCode == 200) {
        log("Chat deleted successfully");
        return true;
      }
      log("Failed to delete chat: ${response.statusCode}");
      return false;
    } catch (e) {
      log("Error deleting chat: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchChats() async {
    try {
      final response = await _baseService.get(ExternalEndPoints.fetchChats);

      if (response.statusCode == 200) {
         log(response.body);
        final data = jsonDecode(response.body);
        log("Chats fetched successfully");
        return data;
      }
      throw Exception("Failed to fetch chats: ${response.statusCode}");
    } catch (e) {
      log("Error fetching chats: $e");
      rethrow;
    }
  }

  Future<bool> markRead(String conversationId) async {
    try {
      final response = await _baseService.put(
        ExternalEndPoints.markread,
        body:{},
        routeParameters: {'conversationId': conversationId},
      );

      if (response.statusCode == 200) {
        log("Chat marked has changed successfully: $conversationId");
        return true;
      }
      log("Failed to mark chat as read: ${response.statusCode}");
      return false;
    } catch (e) {
      log("Error marking chat as read: $e");
      return false;
    }
  }
  Future<bool> markunRead(String conversationId) async {
    try {
      final response = await _baseService.put(
        ExternalEndPoints.markunread,
        body:{},
        routeParameters: {'conversationId': conversationId},
      );

      if (response.statusCode == 200) {
        log("Chat marked has changed unread successfully: $conversationId");
        return true;
      }
      log("Failed to mark chat as unread: ${response.statusCode}");
      return false;
    } catch (e) {
      log("Error marking chat as unread: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getAllCounts() async {
    try {
      final response = await _baseService.get(ExternalEndPoints.getallcounts);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Unread counts fetched successfully: ${data['unreadCount']}");
        return data;
      }
      throw Exception("Failed to fetch unread counts: ${response.statusCode}");
    } catch (e) {
      log("Error fetching unread counts: $e");
      rethrow;
    }
  }
}

final chatServiceProvider = Provider<ApiChatService>((ref) {
  return ApiChatService();
});
 