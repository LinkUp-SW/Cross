import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      if (response != null) {
        state = DashboardSuccessState();
        statCardsData = response;
      } else {
        state = DashboardErrorState("Failed to fetch data");
      }
    } catch (e) {
      state = DashboardErrorState("An error occurred: $e");
    }
  }
}
