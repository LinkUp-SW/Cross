import 'package:flutter/material.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/admin_panel/model/dashboard_model.dart';

class DashboardService extends BaseService{
  getDashboardData() async {
    try {
      return [
        StatCardsModel(
          title: "Reported Content",
          value: "100",
          changeText: "+10 since yesterday",
          changeColor: Colors.green,
        ),
        StatCardsModel(
          title: "Pending Jobs",
          value: "100",
          changeText: "+10 since yesterday",
          changeColor: Colors.green,
        ),
        StatCardsModel(
          title: "Active Users",
          value: "100",
          changeText: "+10 since yesterday",
          changeColor: Colors.green,
        ),
        StatCardsModel(
          title: "Deleted Accounts",
          value: "10.5%",
          changeText: "+10.1% from last week",
          changeColor: Colors.green,
        ),
      ];
    } catch (e) {
      return null;
    }
  }
}