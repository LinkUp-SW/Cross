import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/admin_panel/model/privilages_model.dart';

class ReportService extends BaseService {
  Future<List<ReportModel>> fetchReports(String status) async {
    final response = await get(
      'api/v1/admin/report',
      queryParameters: {
        'status': status.toLowerCase(),
        'cursor': 0,
        'limit': 50,
      },
    );
    final data = jsonDecode(response.body)['data'];
    return List<ReportModel>.from(
      data['reports'].map((item) => ReportModel.fromJson(item)),
    );
  }

  Future<PostModel> fetchPost(
    String contentType,
    String contentRef,
  ) async {
    final response = await get(
      'api/v1/admin/report/content/:contentType/:contentRef',
      routeParameters: {
        'contentType': contentType,
        'contentRef': contentRef,
      },
    );

    final data = jsonDecode(response.body)['data']['content'];
    log(data.toString());
    return PostModel.fromJson(data);
  }

  Future<void> dismissReport(
    String contentType,
    String contentRef,
  ) async {
    await patch('api/v1/admin/report/resolve/:contentType/:contentRef',
        routeParameters: {
          'contentType': contentType,
          'contentRef': contentRef,
        },
        body: {});
  }

  Future<void> deleteReport(
    String contentType,
    String contentRef,
  ) async {
    log('Deleting report for $contentType and $contentRef');
    final response = await delete(
      'api/v1/admin/report/resolve/:contentType/:contentRef',
      {
        'contentType': contentType,
        'contentRef': contentRef,
      },
    );
    log('Response: ${response.body}');
  }
}
