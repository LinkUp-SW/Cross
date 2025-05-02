// profile/view/add_resume_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart'; // Import dotted_border
import 'package:link_up/features/profile/state/add_resume_state.dart';
import 'package:link_up/features/profile/viewModel/resume_view_model.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart'; // Reuse app bar
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening resume


class AddResumePage extends ConsumerWidget {
  const AddResumePage({super.key});

    // Helper to launch URL safely
   Future<void> _launchUrl(BuildContext context, String? urlString) async {
     if (urlString == null || urlString.isEmpty) return;
     final Uri? url = Uri.tryParse(urlString);
     if (url != null && await canLaunchUrl(url)) {
       try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
       } catch(e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch URL: $e'), backgroundColor: Colors.red));
       }
     } else if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL: $urlString'), backgroundColor: Colors.red));
     }
   }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeViewModelProvider);
    final viewModel = ref.read(resumeViewModelProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final theme = Theme.of(context);

    File? selectedFile;
    if (resumeState is ResumeFileSelected) {
      selectedFile = resumeState.selectedFile;
    } else if (resumeState is ResumeUploading) {
       selectedFile = resumeState.uploadingFile;
    }

    String? currentResumeUrl;
    String? currentFileName;
     if (resumeState is ResumePresent) {
        currentResumeUrl = resumeState.resumeUrl;
        currentFileName = resumeState.fileName ?? "View Resume";
     } else if (resumeState is ResumeUploadSuccess) {
        currentResumeUrl = resumeState.newResumeUrl;
        currentFileName = resumeState.newFileName ?? "View Resume";
     }


    ref.listen<ResumeState>(resumeViewModelProvider, (previous, next) {
       // Show success/error messages
       if (next is ResumeError) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(next.message), backgroundColor: Colors.red),
           );
       } else if (next is ResumeUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Resume uploaded successfully!"), backgroundColor: Colors.green),
           );
           // Optionally pop the screen after success
           // Future.delayed(const Duration(seconds: 1), () => GoRouter.of(context).pop());
       } else if (next is ResumeDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Resume deleted successfully!"), backgroundColor: Colors.green),
           );
       }
       // Handle transitions away from loading states if needed
        if (previous is ResumeUploading && next is! ResumeUploading) {
           // Potentially hide loading indicator not handled by button state
        }
        if (previous is ResumeDeleting && next is! ResumeDeleting) {
            // Hide loading indicator
        }
    });


    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Add Resume",
              onClosePressed: () => GoRouter.of(context).pop(),
            ),
            Expanded(
              child: Container(
                width: double.infinity, // Ensure container takes full width
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Display current resume info if present
                    if(resumeState is ResumePresent || resumeState is ResumeUploadSuccess)
                      Padding(
                         padding: EdgeInsets.only(bottom: 20.h),
                         child: Column(
                            children: [
                              Text("Current Resume:", style: TextStyles.font16_600Weight.copyWith(color: theme.textTheme.bodyLarge?.color)),
                              SizedBox(height: 8.h),
                              InkWell(
                                 onTap: () => _launchUrl(context, currentResumeUrl),
                                 child: Text(
                                    currentFileName ?? "View Resume",
                                    style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightBlue, decoration: TextDecoration.underline),
                                    textAlign: TextAlign.center,
                                 ),
                              ),
                              SizedBox(height: 10.h),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                                tooltip: "Delete Resume",
                                onPressed: resumeState is ResumeDeleting ? null : () {
                                   // Add confirmation dialog
                                   showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                         title: const Text('Delete Resume?'),
                                         content: const Text('Are you sure you want to delete your current resume?'),
                                         actions: [
                                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                                            TextButton(
                                               onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  viewModel.deleteResume();
                                               },
                                               child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                         ],
                                      ),
                                   );
                                },
                              ),
                              Divider(height: 20.h, thickness: 1, color: AppColors.lightGrey.withOpacity(0.5)),
                              Text("Upload a new PDF to replace the current one.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey), textAlign: TextAlign.center),
                              SizedBox(height: 10.h),
                            ],
                         ),
                      ),

                     if (resumeState is ResumeLoading)
                       const Center(child: CircularProgressIndicator()),

                     if (resumeState is! ResumeLoading) ...[
                        Text(
                           "Upload your resume in PDF format (max 2MB)",
                           style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                           textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),

                        // File Picker Area
                        InkWell(
                          onTap: (resumeState is ResumeUploading || resumeState is ResumeDeleting) ? null : () => viewModel.pickResumeFile(),
                          child: DottedBorder(
                            color: AppColors.lightGrey,
                            strokeWidth: 1,
                            dashPattern: const [6, 6],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12.r),
                            padding: EdgeInsets.all(20.w),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, size: 40.sp, color: AppColors.lightGrey),
                                  SizedBox(height: 10.h),
                                  Text(
                                    selectedFile != null
                                      ? selectedFile.path.split('/').last // Show selected filename
                                      : "Click to browse",
                                    style: TextStyles.font14_500Weight.copyWith(color: theme.textTheme.bodyLarge?.color),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4.h),
                                   if(selectedFile == null) // Only show format text if no file selected
                                     Text(
                                       "PDF format only, max 2MB",
                                       style: TextStyles.font12_400Weight.copyWith(color: AppColors.lightGrey),
                                       textAlign: TextAlign.center,
                                     ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Upload Button
                       SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (selectedFile == null || resumeState is ResumeUploading || resumeState is ResumeDeleting)
                                ? null // Disable if no file or during operations
                                // FIX: Add null assertion '!' to selectedFile
                                : () => viewModel.uploadResume(selectedFile!),
                            style: (isDarkMode
                                ? buttonStyles.wideBlueElevatedButtonDark()
                                : buttonStyles.wideBlueElevatedButton())
                                .copyWith(minimumSize: MaterialStateProperty.all(Size.fromHeight(50.h))),
                            child: (resumeState is ResumeUploading)
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                                : Text(
                                   (resumeState is ResumePresent || resumeState is ResumeUploadSuccess) ? "Upload New Resume" : "Upload Resume",
                                   style: TextStyles.font15_500Weight.copyWith(color: isDarkMode ? AppColors.darkMain : AppColors.lightMain)
                                ),
                          ),
                        ),
                     ] // End of content shown when not loading
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}