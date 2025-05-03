import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:link_up/features/signUp/widgets/widgets.dart';

class CompanyStatisticsCarousel extends ConsumerStatefulWidget {
  const CompanyStatisticsCarousel({super.key});

  @override
  _CompanyStatisticsCarouselState createState() =>
      _CompanyStatisticsCarouselState();
}

class _CompanyStatisticsCarouselState
    extends ConsumerState<CompanyStatisticsCarousel> {
  String selectedRange = "Past Week";
  List<Widget> graphWidgets = [];
  final TextEditingController _companySearchController =
      TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _generateStatistics();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _companySearchController.dispose();
    super.dispose();
  }

  void _generateStatistics() {
    final xVals = _getXValues(selectedRange);

    graphWidgets = List.generate(
      4,
      (index) {
        final isBarChart = index % 2 == 0; // Alternate
        final yVals = List.generate(xVals.length, (i) => _randomValue());
        return _buildGraph(
          title: "Graph ${index + 1} - $selectedRange",
          xValues: xVals,
          yValues: yVals,
          isBarChart: isBarChart,
        );
      },
    );
  }

  int _randomValue() {
    return (20 + (80 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000))
        .toInt();
  }

  List<String> _getXValues(String range) {
    switch (range) {
      case "Past Week":
        return ["M", "T", "W", "T", "F", "S", "S"];
      case "Past Month":
        return ["Wk1", "Wk2", "Wk3", "Wk4"];
      case "Past Year":
        return ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"];
      case "Past Decade":
        return List.generate(10, (i) => (20 + i).toString());
      default:
        return [];
    }
  }

  Widget _buildGraph({
    required String title,
    required List<String> xValues,
    required List<int> yValues,
    required bool isBarChart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: yValues.length * 60,
              child: isBarChart
                  ? BarChart(_buildBarData(xValues, yValues))
                  : LineChart(_buildLineData(xValues, yValues)),
            ),
          ),
        ),
      ],
    );
  }

  BarChartData _buildBarData(List<String> xValues, List<int> yValues) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles:
              SideTitles(showTitles: true, reservedSize: 40, interval: 20),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < xValues.length) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(xValues[index],
                      style: const TextStyle(fontSize: 12)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      barGroups: List.generate(
        yValues.length,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: yValues[index].toDouble(),
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              width: 30,
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
      maxY: 100,
    );
  }

  LineChartData _buildLineData(List<String> xValues, List<int> yValues) {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < xValues.length) {
                return Text(xValues[index],
                    style: const TextStyle(fontSize: 12));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            yValues.length,
            (i) => FlSpot(i.toDouble(), yValues[i].toDouble()),
          ),
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        )
      ],
      maxY: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: graphWidgets.length,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutocompleteSearchInput(
              controller: _companySearchController,
              label: "Search Company",
              searchType: SearchType.company,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedRange,
                  items: [
                    "Past Week",
                    "Past Month",
                    "Past Year",
                    "Past Decade",
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedRange = newValue!;
                      _generateStatistics();
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _generateStatistics();
                    setState(() {});
                  },
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: List.generate(
                graphWidgets.length,
                (index) => Tab(text: "Graph ${index + 1}"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 420,
              child: TabBarView(
                children: graphWidgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
