//api hits and response data transfere
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/model/statistics_model.dart';

class StatisticsState {
  final List<GraphData> graphs;
  final bool isLoading;
  final String selectedRange;

  StatisticsState({
    required this.graphs,
    required this.isLoading,
    required this.selectedRange,
  });

  StatisticsState copyWith({
    List<GraphData>? graphs,
    bool? isLoading,
    String? selectedRange,
  }) {
    return StatisticsState(
      graphs: graphs ?? this.graphs,
      isLoading: isLoading ?? this.isLoading,
      selectedRange: selectedRange ?? this.selectedRange,
    );
  }

  factory StatisticsState.initial() {
    return StatisticsState(graphs: [], isLoading: false, selectedRange: '30days');
  }
}
