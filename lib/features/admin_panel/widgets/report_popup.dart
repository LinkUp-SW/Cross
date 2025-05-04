import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/widgets/posts.dart';

class ReportPopup extends StatelessWidget {
  final String type;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final PostModel? post;
  final bool isLoading;

  const ReportPopup({
    super.key,
    required this.type,
    required this.onAccept,
    required this.onReject,
    this.post,
    this.isLoading = false,
  });

  Widget _buildContentForType(String type) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (type.toLowerCase()) {
      case 'post':
      case 'comment':
        return post != null
            ? Posts(post: post!, inFeed: false, showBottom: false)
            : const Text("⚠️ Unable to load content.");
      case 'job listing':
        return const Text(
          "This is a Job Listing preview.\n(You can later insert the actual job details widget here.)",
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
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: maxWidth,
          height: maxHeight,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // Title
              const Text(
                'Report Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),

              // Content area with scrolling
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContentForType(type),
                ),
              ),
              SizedBox(height: 20.h),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: onAccept,
                    child: Row(
                      children: const [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Dismiss'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: onReject,
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showReportPopup({
  required BuildContext context,
  required String type,
  required VoidCallback onAccept,
  required VoidCallback onReject,
  PostModel? post,
  bool isLoading = false,
}) {
  return showDialog(
    context: context,
    builder: (context) => ReportPopup(
      type: type,
      post: post,
      isLoading: isLoading,
      onAccept: onAccept,
      onReject: onReject,
    ),
  );
}
