import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/model/dashboard_card_model.dart';
import 'package:link_up/features/admin_panel/model/dashboard_model.dart';
import 'package:link_up/features/admin_panel/services/dashboard_service.dart';
import 'package:link_up/features/admin_panel/state/dashboard_states.dart';

final dashboardServiceProvider = Provider((ref) => DashboardService());

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardStates>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  return DashboardNotifier(service);
});

class DashboardNotifier extends StateNotifier<DashboardStates> {
  final DashboardService _dashboardService;
  List<StatCardsModel> statCardsData = [];
  JobPostingModel jobPostingModel = JobPostingModel(
    approvedTodayCount: 0,
    rejectedTodayCount: 0,
    pendingCount: 0,
  );
  DashboardNotifier(this._dashboardService) : super(DashboardInitialState());

  void init() {
    state = DashboardInitialState();
  }

  void dispose() {
    state = DashboardInitialState();
  }

  Future<void> getDashboardData() async {
    try {
      state = DashboardLoadingState();

      final response = await _dashboardService.getDashboardData();
      log("Dashboard response: $response");
      if (response != null) {
        state = DashboardSuccessState();
        statCardsData =
            response.sublist(0, response.length - 1).cast<StatCardsModel>();
        jobPostingModel = response.last as JobPostingModel;
      } else {
        state = DashboardErrorState("Failed to fetch data");
      }
    } catch (e) {
      state = DashboardErrorState("An error occurred: $e");
    }
  }
}
