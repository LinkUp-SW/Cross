import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/admin_panel/model/privilages_model.dart';
import 'package:link_up/features/admin_panel/state/privilages_state.dart';
import 'package:link_up/features/admin_panel/viewModel/privilages_provider.dart';
import 'package:link_up/features/admin_panel/widgets/admin_drawer.dart';
import 'package:link_up/features/admin_panel/widgets/report_popup.dart';
import 'package:link_up/features/admin_panel/widgets/reports.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final reportNotifier = ref.read(reportProvider.notifier);

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/5559852.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Reports",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Resolved"),
            Tab(text: "All Reports"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: switch (reportState) {
          ReportInitial() ||
          ReportLoading() =>
            const Center(child: CircularProgressIndicator()),
          ReportError(:final message) => Center(child: Text('❌ $message')),
          ReportLoaded(:final reports) => TabBarView(
              controller: _tabController,
              children: [
                _buildTab(reports, "Pending", reportNotifier),
                _buildTab(reports, "Resolved", reportNotifier),
                _buildTab(reports, "All", reportNotifier),
              ],
            ),
        },
      ),
    );
  }

  Widget _buildTab(
    List<ReportModel> allReports,
    String tab,
    ReportNotifier notifier,
  ) {
    final reports = tab == "All"
        ? allReports
        : allReports.where((r) => r.status == tab).toList();

    return RefreshIndicator(
      onRefresh: () async => await notifier.fetchReports(),
      child: reports.isEmpty
          ? const Center(child: Text("No reports."))
          : ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final report = reports[i];
                final reportCard = reportsCard(
                  textId: report.id,
                  description: report.description,
                  status: report.status,
                  type: report.type,
                );

                return report.status == "Pending"
                    ? GestureDetector(
                        onTap: () {
                          showReportPopup(
                            context: context,
                            type: report.type,
                            onAccept: () {
                              Navigator.pop(context);
                              notifier.resolveReport(report.id);
                            },
                            onReject: () {
                              Navigator.pop(context);
                              notifier.resolveReport(report.id);
                            },
                          );
                        },
                        child: reportCard,
                      )
                    : reportCard;
              },
            ),
    );
  }
}
