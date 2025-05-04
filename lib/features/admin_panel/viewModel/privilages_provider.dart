// privilages_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/services/privilages_service.dart';
import 'package:link_up/features/admin_panel/state/privilages_state.dart';
import 'package:link_up/features/admin_panel/model/privilages_model.dart';

final reportServiceProvider = Provider((ref) => ReportService());

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportNotifier(service);
});

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportService _service;

  ReportNotifier(this._service) : super(const ReportInitial()) {
    fetchReports('Pending');
  }

  Future<void> fetchReports(String status) async {
    state = const ReportLoading();
    try {
      final reports = await _service.fetchReports(status);
      state = ReportLoaded(reports);
    } catch (_) {
      state = const ReportError('Failed to load reports');
    }
  }

  /// Dismiss (mark as resolved)
  Future<void> dismissReport(String contentType, String contentRef) async {
    if (state is! ReportLoaded) return;
    final current = (state as ReportLoaded).reports;
    try {
      await _service.dismissReport(contentType, contentRef);
      final updated = current
          .map((r) => (r.contentRef == contentRef && r.type == contentType)
              ? r.copyWith(status: 'Resolved')
              : r)
          .toList();
      state = ReportLoaded(updated);
    } catch (_) {
      state = const ReportError('Failed to dismiss report');
    }
  }

  /// Delete (remove from list)
  Future<void> removeReport(String contentType, String contentRef) async {
    if (state is! ReportLoaded) return;
    final current = (state as ReportLoaded).reports;
    try {
      await _service.deleteReport(contentType, contentRef);
      final updated = current
          .where((r) => !(r.contentRef == contentRef && r.type == contentType))
          .toList();
      state = ReportLoaded(updated);
    } catch (_) {
      state = const ReportError('Failed to delete report');
    }
  }
}
