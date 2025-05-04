import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/admin_panel/model/dashboard_card_model.dart';
import 'package:link_up/features/admin_panel/model/dashboard_model.dart';

class DashboardService extends BaseService {
  Future<List<dynamic>> getDashboardData() async {
    try {
      final response = await get('api/v1/admin/dashboard');
      log("Dashboard response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return [
          StatCardsModel(
            title: "Reported Content",
            value: data['summary']['reported_content'].toString(),
            changeText: data['summary']['delta']['reports'],
            changeColor: Colors.green,
          ),
          StatCardsModel(
            title: "Total Jobs",
            value: data['summary']['total_jobs'].toString(),
            changeText: data['summary']['delta']['reports'],
            changeColor: Colors.green,
          ),
          StatCardsModel(
            title: "Total Users",
            value: data['summary']['total_users'].toString(),
            changeText: data['summary']['delta']['users'],
            changeColor: Colors.green,
          ),
          JobPostingModel(
            approvedTodayCount: data['job_management']['approved_today'],
            rejectedTodayCount: data['job_management']['rejected_today'],
            pendingCount: data['job_management']['pending_approval'],
          ),
        ];
      } else {
        throw Exception("Failed to load dashboard data");
      }
    } catch (e) {
      throw Exception("Error fetching dashboard data: $e");
    }
  }
}
