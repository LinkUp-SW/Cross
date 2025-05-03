import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/state/dashboard_states.dart';
import 'package:link_up/features/admin_panel/viewModel/dashboard_provider.dart';
import 'package:link_up/features/admin_panel/widgets/admin_drawer.dart';
import 'package:link_up/features/admin_panel/widgets/dashboard_card.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    ref.listen<DashboardStates>(dashboardProvider, (previous, next) {
      if (next is DashboardInitialState) {
        dashboardNotifier.getDashboardData();
      } else if (next is DashboardErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
      }
    });
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/5559852.png'),
                fit: BoxFit.cover),
          ),
        ),
        title: const Text('Dashboard',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatCard(
              title: "Reported Content",
              value: "100",
              changeTexts: [
                "+10 since last week",
                "+45 since last month",
                "+320 since last year",
                "+1200 since last decade",
              ],
            ),
            StatCard(
              title: "Pending Jobs",
              value: "100",
              changeTexts: [
                "+10 since last week",
                "+45 since last month",
                "+320 since last year",
                "+1200 since last decade",
              ],
            ),
            StatCard(
              title: "Active Users",
              value: "100",
              changeTexts: [
                "+10 since last week",
                "+45 since last month",
                "+320 since last year",
                "+1200 since last decade",
              ],
            ),
            StatCard(
              title: "Deleted Users",
              value: "100",
              changeTexts: [
                "+10 since last week",
                "+45 since last month",
                "+320 since last year",
                "+1200 since last decade",
              ],
            ),
            const JobPostingWidget(
              pendingCount: 2,
              approvedTodayCount: 2,
              rejectedTodayCount: 2,
            ),
          ],
        )),
      ),
    );
  }
}
