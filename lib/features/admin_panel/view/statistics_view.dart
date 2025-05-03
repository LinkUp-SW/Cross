import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/widgets/admin_drawer.dart';
import 'package:link_up/features/admin_panel/widgets/app_statistics_carousle.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/5559852.png'),
                fit: BoxFit.cover),
          ),
        ),
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('App Statistics',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),

            const SizedBox(height: 25),
            // AppStatisticsCarousel is now an Expanded widget that fills the remaining space
            const AppStatisticsCarousel(),
          ],
        ),
      ),
    );
  }
}
