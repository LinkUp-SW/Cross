import 'package:flutter/material.dart';
import 'package:link_up/features/admin_panel/model/job_report_model.dart';

class JobReportCard extends StatelessWidget {
  final JobReportModel jobReport;

  const JobReportCard({super.key, required this.jobReport});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title
            Text(
              jobReport.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Description
            SingleChildScrollView(
              child: Text(
                jobReport.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            // Organization
            Text(
              'Organization: ${jobReport.organization.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
