
import 'package:link_up/features/admin_panel/model/privilages_model.dart';

class ReportService {
  Future<List<ReportModel>> fetchReports() async {
    return [
      ReportModel(
        id: 'REP-001',
        type: 'Comment',
        descriptions: ['User used offensive language.'],
        status: 'Pending',
      ),
      ReportModel(
        id: 'REP-002',
        type: 'Post',
        descriptions: ['Inappropriate image posted.'],
        status: 'Resolved',
      ),
      // Add more dummy data here
    ];
  }

  Future<void> resolveReport(String id) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
  }
}
