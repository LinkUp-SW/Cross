// THEMED VERSION of StatCard and JobPostingWidget
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final int changeValue;
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
    final theme = Theme.of(context);
    final String changeText =
        '${widget.changeValue > 0 ? '+' : ''}${widget.changeValue} from yesterday';
    final Color changeColor =
        widget.changeValue >= 0 ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: TextStyles.font18_600Weight.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              )),
          const SizedBox(height: 8),
          Text(widget.value,
              style: TextStyles.font20_700Weight.copyWith(
                color: theme.colorScheme.inverseSurface,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Posting Management',
            style: TextStyles.font20_700Weight.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review and manage job listings',
            style: TextStyles.font16_400Weight.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow(context, 'Pending approval', pendingCount),
          _buildStatusRow(context, 'Approved today', approvedTodayCount),
          _buildStatusRow(context, 'Rejected today', rejectedTodayCount),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyles.font14_500Weight.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              )),
          Text(
            count.toString(),
            style: TextStyles.font18_700Weight.copyWith(
              color: theme.colorScheme.inverseSurface,
            ),
          ),
        ],
      ),
    );
  }
}
