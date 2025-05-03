import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportPopup extends StatelessWidget {
  final String type;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ReportPopup({
    super.key,
    required this.type,
    required this.onAccept,
    required this.onReject,
  });

  Widget _buildContentForType(String type) {
    switch (type.toLowerCase()) {
      case 'job listing':
        return const Text(
          "This is a Job Listing preview.\n(You can later insert the actual job details widget here.)",
          textAlign: TextAlign.center,
        );
      case 'comment':
        return const Text(
          "This is a Comment preview.\n(A comment content widget would go here.)",
          textAlign: TextAlign.center,
        );
      case 'post':
        return const Text(
          "This is a Post preview.\n(You might render a full post card here.)",
          textAlign: TextAlign.center,
        );
      default:
        return const Text(
          "Unknown report type.\nPlease check the data.",
          textAlign: TextAlign.center,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 70),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Report Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                _buildContentForType(type),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: onAccept,
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 5),
                      const Text('Dissmiss')
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: onReject,
                  child: Row(children: [
                    const Icon(Icons.close, color: Colors.white),
                    SizedBox(width: 5),
                    const Text('Delete')
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showReportPopup({
  required BuildContext context,
  required String type,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  return showDialog(
    context: context,
    builder: (context) => ReportPopup(
      type: type,
      onAccept: onAccept,
      onReject: onReject,
    ),
  );
}
