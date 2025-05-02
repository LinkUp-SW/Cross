import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppStatisticsCarousel extends StatefulWidget {
  const AppStatisticsCarousel({super.key});

  @override
  _AppStatisticsCarouselState createState() => _AppStatisticsCarouselState();
}

class _AppStatisticsCarouselState extends State<AppStatisticsCarousel> {
  String selectedRange = "Past Week";
  List<Widget> graphWidgets = [];

  @override
  void initState() {
    super.initState();
    _generateStatistics();
  }

  void _generateStatistics() {
    graphWidgets.clear();

    switch (selectedRange) {
      case "Past Week":
        graphWidgets = List.generate(
          4,
          (index) => _buildGraph(
            title: "Graph ${index + 1} - Past Week",
            xValues: ["M", "T", "W", "T", "F", "S", "S"],
            yValues: List.generate(7, (i) => _randomValue()),
          ),
        );
        break;
      case "Past Month":
        graphWidgets = List.generate(
          4,
          (index) => _buildGraph(
            title: "Graph ${index + 1} - Past Month",
            xValues: ["Wk1", "Wk2", "Wk3", "Wk4"],
            yValues: List.generate(4, (i) => _randomValue()),
          ),
        );
        break;
      case "Past Year":
        graphWidgets = List.generate(
          4,
          (index) => _buildGraph(
            title: "Graph ${index + 1} - Past Year",
            xValues: [
              "J",
              "F",
              "M",
              "A",
              "M",
              "J",
              "J",
              "A",
              "S",
              "O",
              "N",
              "D"
            ],
            yValues: List.generate(12, (i) => _randomValue()),
          ),
        );
        break;
      case "Past Decade":
        graphWidgets = List.generate(
          4,
          (index) => _buildGraph(
            title: "Graph ${index + 1} - Past Decade",
            xValues: List.generate(10, (i) => (20 + i).toString()),
            yValues: List.generate(10, (i) => _randomValue()),
          ),
        );
        break;
    }
  }

  int _randomValue() {
    return (20 + (80 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000))
        .toInt();
  }

  Widget _buildGraph({
    required String title,
    required List<String> xValues,
    required List<int> yValues,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: yValues.length * 60, // Wider bars: 60px per bar
              child: BarChart(
                BarChartData(
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
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < xValues.length) {
                            return SideTitleWidget(
                              fitInside:
                                  SideTitleFitInsideData.fromTitleMeta(meta),
                              meta: meta,
                              child: Text(
                                xValues[index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade900
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 30,
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.blue.shade900, width: 1),
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
                ),
              ),
            ),
          ),
        ),
      ],
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
