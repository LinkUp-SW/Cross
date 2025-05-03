import 'dart:async';
import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final List<String> changeTexts; // Animated list of changes
  final Duration interval;
  final Color changeColor;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.changeTexts,
    this.interval = const Duration(seconds: 2),
    this.changeColor = Colors.green,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.changeTexts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures card expands horizontally
      constraints: BoxConstraints(minHeight: 120),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFD), Color(0xFFE6EEF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 18,
                  )),
          const SizedBox(height: 8),
          Text(widget.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  )),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              widget.changeTexts[_currentIndex],
              key: ValueKey<String>(widget.changeTexts[_currentIndex]),
              style: TextStyle(
                color: widget.changeColor,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class JobPostingWidget extends StatelessWidget {
  final int pendingCount;
  final int approvedTodayCount;
  final int rejectedTodayCount;

  const JobPostingWidget({
    super.key,
    required this.pendingCount,
    required this.approvedTodayCount,
    required this.rejectedTodayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Posting Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review and manage job listings',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Pending approval', pendingCount),
          _buildStatusRow('Approved today', approvedTodayCount),
          _buildStatusRow('Rejected today', rejectedTodayCount),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
