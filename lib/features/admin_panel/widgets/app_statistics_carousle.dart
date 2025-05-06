import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:link_up/features/admin_panel/viewModel/statistics_provider.dart';
import 'package:link_up/features/admin_panel/model/statistics_model.dart';

class AppStatisticsCarousel extends ConsumerStatefulWidget {
  const AppStatisticsCarousel({super.key});

  @override
  ConsumerState<AppStatisticsCarousel> createState() =>
      _AppStatisticsCarouselState();
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
          SizedBox(height: 10),
          state.isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
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
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: isActive ? 16 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: isActive ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isActive ? BorderRadius.circular(4) : null,
        color: isActive ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildGraphCard(GraphData graph) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    // Calculate min and max values to set appropriate Y axis range
    double minY = 0;
    double maxY = 10;

    if (graph.yValues.isNotEmpty) {
      maxY = graph.yValues.reduce((a, b) => a > b ? a : b);
      minY = graph.yValues.reduce((a, b) => a < b ? a : b);

      // Add some padding to the max/min values
      maxY = maxY * 1.2;
      minY = minY > 0 ? 0 : minY * 1.2;

      // Ensure we have a reasonable range for the Y axis
      if (maxY - minY < 10) {
        maxY = minY + 10;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final spotIndex = touchedSpot.spotIndex;
                    final xLabel = graph.xValues.length > spotIndex
                        ? graph.xValues[spotIndex]
                        : '';
                    return LineTooltipItem(
                      '${xLabel}: ${touchedSpot.y.toStringAsFixed(1)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                }),
            handleBuiltInTouches: true,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < graph.xValues.length) {
                    return SideTitleWidget(
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      meta: meta,
                      child: Text(
                        graph.xValues[value.toInt()],
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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
                interval: (maxY - minY) / 5,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                graph.yValues.length,
                (i) => FlSpot(i.toDouble(), graph.yValues[i]),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.4),
                    Colors.blue.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(GraphData graph) {
    // Calculate an appropriate max Y value
    double maxY = 10;

    if (graph.yValues.isNotEmpty) {
      maxY = graph.yValues.reduce((a, b) => a > b ? a : b) * 1.2;
      // Ensure we have a reasonable minimum
      maxY = maxY < 10 ? 10 : maxY;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${graph.xValues[groupIndex]}: ${rod.toY.toStringAsFixed(1)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < graph.xValues.length) {
                    return SideTitleWidget(
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      meta: meta,
                      child: Text(
                        graph.xValues[value.toInt()],
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          barGroups: List.generate(
            graph.yValues.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: graph.yValues[i],
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  width: graph.yValues.length > 8 ? 12 : 20,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
