// THEMED ONLY VERSION
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/admin_panel/model/job_report_model.dart';
import 'package:link_up/features/admin_panel/model/privilages_model.dart';
import 'package:link_up/features/admin_panel/state/privilages_state.dart';
import 'package:link_up/features/admin_panel/viewModel/privilages_provider.dart';
import 'package:link_up/features/admin_panel/widgets/admin_drawer.dart';
import 'package:link_up/features/admin_panel/widgets/report_popup.dart';
import 'package:link_up/features/admin_panel/widgets/reports.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/shared/themes/text_styles.dart';

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
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final tabName = _getTabName(_tabController.index);
    final status = tabName == "All" ? "" : tabName;
    ref.read(reportProvider.notifier).fetchReports(status);
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return "Pending";
      case 1:
        return "Resolved";
      case 2:
        return "All";
      default:
        return "All";
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final theme = Theme.of(context);

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
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Reports",
          style: TextStyles.font25_700Weight.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.colorScheme.primary,
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
                _buildTab(reports, "Pending"),
                _buildTab(reports, "Resolved"),
                _buildTab(reports, "All"),
              ],
            ),
        },
      ),
    );
  }

  Widget _buildTab(List<ReportModel> allReports, String tab) {
    final reports = tab == "All"
        ? allReports
        : allReports
            .where((r) => r.status.toLowerCase() == tab.toLowerCase())
            .toList();

    return RefreshIndicator(
      onRefresh: () {
        final tabName = _getTabName(_tabController.index);
        final status = tabName == "All" ? "" : tabName;
        return ref.read(reportProvider.notifier).fetchReports(status);
      },
      child: reports.isEmpty
          ? const Center(child: Text("No reports."))
          : ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final report = reports[i];
                final card = reportsCard(
                  textId: report.id,
                  descriptions: report.descriptions,
                  status: report.status,
                  type: report.type,
                );

                if (report.status.toLowerCase() != "pending") return card;

                return GestureDetector(
                  onTap: () async {
                    final notifier = ref.read(reportProvider.notifier);
                    if (report.contentRef != null &&
                        (report.type.toLowerCase() == 'post' ||
                            report.type.toLowerCase() == 'comment' ||
                            report.type.toLowerCase() == 'job')) {
                      showReportPopup(
                        context: context,
                        type: report.type,
                        isLoading: true,
                        onAccept: () {},
                        onReject: () {},
                      );

                      try {
                        final post = await ref
                            .read(reportServiceProvider)
                            .fetchPost(report.type, report.contentRef!);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        showReportPopup(
                          context: context,
                          type: report.type,
                          post: post is PostModel ? post : null,
                          job: post is JobReportModel ? post : null,
                          onAccept: () {
                            Navigator.pop(context);
                            notifier.dismissReport(
                                report.type, report.contentRef!);
                          },
                          onReject: () {
                            Navigator.pop(context);
                            notifier.removeReport(
                                report.type, report.contentRef!);
                          },
                        );
                      } catch (_) {
                        log("Error fetching post: $_");
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Failed to fetch reported content")),
                        );
                      }
                    } else {
                      showReportPopup(
                        context: context,
                        type: report.type,
                        onAccept: () {
                          Navigator.pop(context);
                          notifier.dismissReport(
                              report.type, report.contentRef ?? report.id);
                        },
                        onReject: () {
                          Navigator.pop(context);
                          notifier.removeReport(
                              report.type, report.contentRef ?? report.id);
                        },
                      );
                    }
                  },
                  child: card,
                );
              },
            ),
    );
  }
}
