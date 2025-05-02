import 'package:link_up/features/admin_panel/model/privilages_model.dart';

sealed class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final List<ReportModel> reports;
  const ReportLoaded(this.reports);
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
}
