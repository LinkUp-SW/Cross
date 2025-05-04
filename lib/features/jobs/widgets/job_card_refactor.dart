import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/jobs_screen_utils.dart';
import 'package:go_router/go_router.dart';

class JobsCard extends ConsumerWidget {
  final bool isDarkMode;
  final JobsCardModel data;

  const JobsCard({
    super.key,
    required this.isDarkMode,
    required this.data,
  });

  Widget _buildCompanyLogo() {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: data.companyPicture.isNotEmpty
            ? Image.network(
                data.companyPicture,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCompanyPlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildCompanyPlaceholder(isLoading: true);
                },
              )
            : _buildCompanyPlaceholder(),
      ),
    );
  }

  Widget _buildCompanyPlaceholder({bool isLoading = false}) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                  ),
                ),
              )
            : Icon(
                Icons.business,
                size: 24.w,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/jobs/details/${data.cardId}');
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
            border: Border(
              bottom: BorderSide(
                width: 0.3.w,
                color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.0.w,
                  vertical: 8.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildCompanyLogo(),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.jobTitle,
                                  style: TextStyles.font15_700Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  data.companyName,
                                  style: TextStyles.font14_500Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                        size: 20.w,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(width: 32.w, height: 32.h),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 64.w),
                child: Text(
                  '${data.location}, ${data.workType}',
                  style: TextStyles.font15_700Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 64.w,
                  bottom: 8.h,
                  top: 4.h,
                ),
                child: Text(
                  getDaysDifference(data.postDate),
                  style: TextStyles.font13_700Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}