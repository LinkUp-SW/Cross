import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class reportsCard extends ConsumerStatefulWidget {
  final String textId;
  final List<String> descriptions;
  final String status;
  final String type;

  const reportsCard({
    super.key,
    required this.textId,
    required this.descriptions,
    required this.status,
    required this.type,
  });

  @override
  ConsumerState<reportsCard> createState() => _ReportsState();
}

class _ReportsState extends ConsumerState<reportsCard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.descriptions.length > 1) {
      Future.delayed(const Duration(seconds: 3), cycleDescriptions);
    }
  }

  void cycleDescriptions() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.descriptions.length;
    });
    Future.delayed(const Duration(seconds: 3), cycleDescriptions);
  }

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
          // Top Row: Title + Status
          Row(
            children: [
              Text(
                '${widget.type} Report',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.status,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${widget.textId}',
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              widget.descriptions[_currentIndex],
              key: ValueKey<String>(widget.descriptions[_currentIndex]),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
