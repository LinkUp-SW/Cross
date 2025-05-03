import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/job_application_submit_model.dart';
import 'package:link_up/features/jobs/model/job_application_user_model.dart';
import 'package:link_up/features/jobs/viewModel/job_application_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:go_router/go_router.dart';

class JobApplicationDialog extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;

  const JobApplicationDialog({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
  }) : super(key: key);

  @override
  ConsumerState<JobApplicationDialog> createState() => _JobApplicationDialogState();
}

class _JobApplicationDialogState extends ConsumerState<JobApplicationDialog> {
  final TextEditingController _coverLetterController = TextEditingController();
  bool _showCoverLetterField = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobApplicationViewModelProvider.notifier).getApplicationUserData();
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobApplicationViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (state.isSuccess) {
      return _buildSuccessDialog(isDarkMode);
    }

    return Dialog(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500.w),
        child: state.isLoading
            ? _buildLoadingState(isDarkMode)
            : state.isError
                ? _buildErrorState(isDarkMode, state.errorMessage ?? 'Failed to load your profile data')
                : _buildApplicationForm(isDarkMode, state.userData, state.isSubmitting),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Container(
      height: 200.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? Colors.blue.shade200 : Colors.blue,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading your profile...',
            style: TextStyles.font16_500Weight.copyWith(
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, String errorMessage) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.w,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error',
            style: TextStyles.font18_700Weight.copyWith(
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyles.font14_400Weight.copyWith(
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(jobApplicationViewModelProvider.notifier).getApplicationUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.blue.shade700 : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Retry'),
              ),
              SizedBox(width: 16.w),
              OutlinedButton(
                onPressed: () {
                  context.pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDarkMode ? Colors.blue.shade700 : Colors.blue,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode ? Colors.blue.shade200 : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationForm(bool isDarkMode, JobApplicationUserModel? data, bool isSubmitting) {
    if (data == null) {
      return _buildErrorState(isDarkMode, 'Profile data is missing');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apply to ${widget.jobTitle}',
            style: TextStyles.font18_700Weight.copyWith(
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'at ${widget.companyName}',
            style: TextStyles.font14_400Weight.copyWith(
              color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
          ),
          Divider(height: 32.h),
          
          // Profile information section
          _buildProfileSection(isDarkMode, data),
          SizedBox(height: 24.h),
          
          // Resume section
          _buildResumeSection(isDarkMode, data),
          SizedBox(height: 24.h),
          
          // Cover letter option
          Row(
            children: [
              Checkbox(
                value: _showCoverLetterField,
                onChanged: (value) {
                  setState(() {
                    _showCoverLetterField = value ?? false;
                  });
                },
                activeColor: isDarkMode ? Colors.blue.shade700 : Colors.blue,
              ),
              Text(
                'Add a cover letter',
                style: TextStyles.font14_500Weight.copyWith(
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                ),
              ),
            ],
          ),
          
          // Cover letter field
          if (_showCoverLetterField) ...[
            SizedBox(height: 16.h),
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your cover letter here...',
                hintStyle: TextStyle(
                  color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.blue.shade700 : Colors.blue,
                  ),
                ),
                filled: true,
                fillColor: isDarkMode ? AppColors.darkGrey.withOpacity(0.2) : AppColors.lightGrey.withOpacity(0.1),
                contentPadding: EdgeInsets.all(16.w),
              ),
              style: TextStyle(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              ),
            ),
          ],
          
          SizedBox(height: 24.h),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: isSubmitting ? null : () {
                  context.pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () {
                  _submitApplication(data);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Submit Application'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _submitApplication(JobApplicationUserModel data) {
    final applicationData = JobApplicationSubmitModel(
      firstName: data.firstName,
      lastName: data.lastName,
      emailAddress: data.emailAddress,
      phoneNumber: data.phoneNumber,
      countryCode: data.countryCode,
      resume: data.resume,
      coverLetter: _showCoverLetterField ? _coverLetterController.text : null,
    );
    
    ref.read(jobApplicationViewModelProvider.notifier).submitJobApplication(
      jobId: widget.jobId,
      applicationData: applicationData,
    );
  }

  Widget _buildProfileSection(bool isDarkMode, JobApplicationUserModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Profile',
          style: TextStyles.font18_700Weight.copyWith(
            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          color: isDarkMode 
              ? AppColors.darkGrey.withOpacity(0.2) 
              : AppColors.lightGrey.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(
              color: isDarkMode 
                  ? AppColors.darkGrey.withOpacity(0.3) 
                  : AppColors.lightGrey.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Name and Contact Info
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20.sp,
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${data.firstName} ${data.lastName}',
                      style: TextStyles.font16_500Weight.copyWith(
                        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 20.sp,
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      data.emailAddress,
                      style: TextStyles.font14_400Weight.copyWith(
                        color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20.sp,
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${data.countryCode} ${data.phoneNumber}',
                      style: TextStyles.font14_400Weight.copyWith(
                        color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeSection(bool isDarkMode, JobApplicationUserModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Resume',
          style: TextStyles.font18_700Weight.copyWith(
            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
          ),
        ),
        SizedBox(height: 12.h),
        if (data.resume.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkGrey.withOpacity(0.2) : AppColors.lightGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  size: 24.w,
                  color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resume.pdf',
                        style: TextStyles.font14_500Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Your resume will be shared with the employer',
                        style: TextStyles.font12_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: isDarkMode ? Colors.blue.shade200 : Colors.blue,
                  ),
                  onPressed: () {
                    // View resume logic - could launch URL
                  },
                ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 24.w,
                  color: Colors.red,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Resume Attached',
                        style: TextStyles.font14_500Weight.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Please upload a resume in your profile before applying',
                        style: TextStyles.font12_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSuccessDialog(bool isDarkMode) {
    return Dialog(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
           mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Application Submitted!',
              style: TextStyles.font20_700Weight.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your application for ${widget.jobTitle} at ${widget.companyName} has been successfully submitted.',
              textAlign: TextAlign.center,
              style: TextStyles.font14_400Weight.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ref.read(jobApplicationViewModelProvider.notifier).resetState();
                context.pop(true); // Return true to indicate successful submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}