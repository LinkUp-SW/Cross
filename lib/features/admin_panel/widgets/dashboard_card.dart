import 'dart:async';
import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final int changeValue; // Change value (positive or negative)
  final Duration interval;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.changeValue,
    this.interval = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  @override
  Widget build(BuildContext context) {
    final String changeText = '${widget.changeValue > 0 ? '+' : ''}${widget.changeValue} from yesterday';
    final Color changeColor = widget.changeValue >= 0 ? Colors.green : Colors.red;

    return Container(
      width: double.infinity, // Ensures card expands horizontally
      constraints: const BoxConstraints(minHeight: 120),
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
          Text(
            changeText,
            style: TextStyle(
              color: changeColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class JobPostingWidget extends StatefulWidget {
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
  State<JobPostingWidget> createState() => _JobPostingWidgetState();
}

class _JobPostingWidgetState extends State<JobPostingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Posting Management',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review and manage job listings',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Pending approval', widget.pendingCount),
          _buildStatusRow('Approved today', widget.approvedTodayCount),
          _buildStatusRow('Rejected today', widget.rejectedTodayCount),
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
          Text(label,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
