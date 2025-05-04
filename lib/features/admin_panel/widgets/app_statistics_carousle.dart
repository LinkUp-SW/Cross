import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:link_up/features/admin_panel/viewModel/statistics_provider.dart';
import 'package:link_up/features/admin_panel/model/statistics_model.dart';

class AppStatisticsCarousel extends ConsumerStatefulWidget {
  const AppStatisticsCarousel({super.key});

  @override
  ConsumerState<AppStatisticsCarousel> createState() => _AppStatisticsCarouselState();
}

class _AppStatisticsCarouselState extends ConsumerState<AppStatisticsCarousel> {
  String selectedRange = '30days';
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).loadStatistics(selectedRange);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    
    // Take up all available space
    return Expanded(
      child: Column(
        children: [
          _buildRangeSelector(),
          const SizedBox(height: 10),
          state.isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(child: _buildCarousel(state.graphs)),
        ],
      ),
    );
  }

  Widget _buildRangeSelector() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _rangeButton('7days', 'Last 7 Days'),
          _rangeButton('30days', 'Last 30 Days'),
          _rangeButton('90days', 'Last 90 Days'),
          _rangeButton('1year', 'Last Year'),
        ],
      ),
    );
  }

  Widget _rangeButton(String range, String label) {
    final isSelected = selectedRange == range;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() {
            selectedRange = range;
          });
          ref.read(statisticsProvider.notifier).loadStatistics(range);
        },
        child: Text(label),
      ),
    );
  }

  Widget _buildCarousel(List<GraphData> graphs) {
    if (graphs.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        // Make the carousel take most of the available space
        Expanded(
          flex: 9,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: graphs.length,
            itemBuilder: (context, index) {
              return _buildGraphCard(graphs[index]);
            },
          ),
        ),
        // Page indicator at the bottom
        Expanded(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                graphs.length,
                (index) => _buildDotIndicator(index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildGraphCard(GraphData graph) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              graph.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: graph.type == 'bar' 
                  ? _buildBarChart(graph) 
                  : _buildLineChart(graph),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(GraphData graph) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < graph.xValues.length) {
                  return SideTitleWidget(
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    meta: meta,
                    child: Text(graph.xValues[value.toInt()]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  meta: meta,
                  child: Text(value.toInt().toString()),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              graph.yValues.length,
              (i) => FlSpot(i.toDouble(), graph.yValues[i]),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(GraphData graph) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: graph.yValues.isNotEmpty ? graph.yValues.reduce((a, b) => a > b ? a : b) * 1.2 : 100,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < graph.xValues.length) {
                  return SideTitleWidget(
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    meta: meta,
                    child: Text(graph.xValues[value.toInt()]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  meta: meta,
                  child: Text(value.toInt().toString()),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        barGroups: List.generate(
          graph.yValues.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: graph.yValues[i],
                color: Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}