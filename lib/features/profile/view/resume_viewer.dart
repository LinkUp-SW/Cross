// profile/view/resume_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:link_up/shared/themes/colors.dart'; 

class ResumeViewerPage extends StatelessWidget {
  final String? url; // Make URL nullable to handle potential routing issues

  const ResumeViewerPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String effectiveUrl = url ?? ''; // Use empty string if url is null

    // Extract filename for the AppBar title (optional)
    String title = 'Resume';
    if (effectiveUrl.isNotEmpty) {
       final uri = Uri.tryParse(effectiveUrl);
       title = uri?.pathSegments.last.split('?').first ?? 'Resume'; // Basic filename extraction, remove query params like ?fl_attachment
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain, // Theme app bar
        foregroundColor: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
        elevation: 1,
      ),
      // Use conditional rendering based on URL validity
      body: effectiveUrl.isEmpty
          ? const Center(child: Text('Error: Resume URL is missing.'))
          : const PDF().cachedFromUrl(
              effectiveUrl,
              // Optional: Add headers if needed for authorization (e.g., if URL requires token)
              // headers: {'Authorization': 'Bearer YOUR_TOKEN_IF_NEEDED'},
              placeholder: (progress) => Center(child: Text('Loading: $progress %')),
              errorWidget: (error) => Center(child: Text("Error loading PDF: ${error.toString()}")),
            ),
    );
  }
}