import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class reportsCard extends ConsumerStatefulWidget {
  final String textId;
  final String description;
  final String status;
  final String type; // NEW

  const reportsCard({
    super.key,
    required this.textId,
    required this.description,
    required this.status,
    required this.type,
  });

  @override
  ConsumerState<reportsCard> createState() => _ReportsState();
}

class _ReportsState extends ConsumerState<reportsCard> {
  @override
  Widget build(BuildContext context) {
    final isPending = widget.status == 'Pending';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPending ? Colors.orange : Colors.green,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12.0),
        color: isPending ? Colors.orange.shade50 : Colors.green.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Status Badge
          Row(
            children: [
              Text(
                '${widget.type} Report',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${widget.textId}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(widget.description, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
