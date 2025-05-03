import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/model/statistics_model.dart';
import 'package:link_up/features/admin_panel/services/statistics_service.dart';
import 'package:link_up/features/admin_panel/state/statistics_state.dart';

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final StatisticsService _service;

  StatisticsNotifier(this._service) : super(StatisticsState.initial()) {
    loadStatistics(state.selectedRange);
  }

  Future<void> loadStatistics(String range) async {
    state = state.copyWith(isLoading: true, selectedRange: range);
    final graphs = await _service.fetchStatistics(range);
    state = state.copyWith(graphs: graphs, isLoading: false);
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>(
  (ref) => StatisticsNotifier(StatisticsService()),
);
