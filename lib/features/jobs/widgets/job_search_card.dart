import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/jobs/view/job_details.dart';
import 'package:link_up/features/jobs/viewModel/search_job_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobSearchCard extends ConsumerStatefulWidget {
  final SearchJobModel data;
  const JobSearchCard({
    super.key,
    required this.data,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _JobSearchCardState();
}

class _JobSearchCardState extends ConsumerState<JobSearchCard> {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsPage(jobId: widget.data.jobId),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 10.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: widget.data.companyLogo.isNotEmpty
                        ? Image.network(
                            widget.data.companyLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.business,
                                  size: 30.w,
                                  color: isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.business,
                              size: 30.w,
                              color: isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                    border: Border(
                      bottom: BorderSide(
                        width: 0.3.w,
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightGrey,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            spacing: 4.h,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data.jobTitle,
                                style: TextStyles.font15_500Weight.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                widget.data.companyName,
                                style: TextStyles.font14_500Weight.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.sp,
                                    color: isDarkMode
                                        ? AppColors.darkGrey
                                        : AppColors.lightGrey,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    widget.data.jobLocation,
                                    style: TextStyles.font14_500Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkGrey
                                          : AppColors.lightGrey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildTag(widget.data.workplaceType, isDarkMode),
                                  SizedBox(width: 8.w),
                                  _buildTag(widget.data.experienceLevel, isDarkMode),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Posted ${widget.data.timeAgo}',
                                    style: TextStyles.font13_500Weight.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                  if (widget.data.salary > 0)
                                    Text(
                                      '\$${widget.data.salary}',
                                      style: TextStyles.font14_500Weight.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: Container(
                            width: 35.w,
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.darkMain
                                  : AppColors.lightMain,
                              border: Border.all(
                                color: isDarkMode
                                    ? AppColors.darkGrey
                                    : AppColors.lightGrey,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Handle saving/unsaving job
                              },
                              icon: Icon(
                                widget.data.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20.r,
                                color: widget.data.isSaved
                                    ? Colors.blue
                                    : (isDarkMode
                                        ? AppColors.darkTextColor
                                        : AppColors.lightTextColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyles.font12_400Weight.copyWith(
          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
        ),
      ),
    );
  }
} 