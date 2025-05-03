import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/services/privilages_service.dart';
import 'package:link_up/features/admin_panel/state/privilages_state.dart';

final reportServiceProvider = Provider((ref) => ReportService());

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportNotifier(service);
});

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportService _service;

  ReportNotifier(this._service) : super(const ReportInitial()) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    state = const ReportLoading();
    try {
      final reports = await _service.fetchReports();
      state = ReportLoaded(reports);
    } catch (_) {
      state = const ReportError('Failed to load reports');
    }
  }

  Future<void> resolveReport(String id) async {
    if (state is! ReportLoaded) return;
    final current = (state as ReportLoaded).reports;

    await _service.resolveReport(id);
    final updated = current
        .map((r) => r.id == id ? r.copyWith(status: 'Resolved') : r)
        .toList();
    state = ReportLoaded(updated);
  }
}
