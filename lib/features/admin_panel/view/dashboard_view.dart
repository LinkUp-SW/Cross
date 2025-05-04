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
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(dashboardProvider.notifier);
      notifier.getDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    ref.listen<DashboardStates>(dashboardProvider, (previous, next) {
      if (next is DashboardErrorState) {
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
            dashboardNotifier.statCardsData.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(strokeWidth: 6),
                    ),
                  )
                : Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dashboardNotifier.statCardsData.length,
                        itemBuilder: (context, index) {
                          final card = dashboardNotifier.statCardsData[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: StatCard(
                                title: card.title!,
                                value: card.value!,
                                changeValue: card.changeText!),
                          );
                        },
                      ),
                      JobPostingWidget(
                        pendingCount:
                            dashboardNotifier.jobPostingModel.pendingCount,
                        approvedTodayCount: dashboardNotifier
                            .jobPostingModel.approvedTodayCount,
                        rejectedTodayCount: dashboardNotifier
                            .jobPostingModel.rejectedTodayCount,
                      ),
                    ],
                  ),
          ],
        )),
      ),
    );
  }
}
