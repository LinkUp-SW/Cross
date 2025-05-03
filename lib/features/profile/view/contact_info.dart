import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart'; 
import 'package:link_up/features/profile/model/contact_info_model.dart';
import 'package:link_up/features/profile/state/contact_info_state.dart';
import 'package:link_up/features/profile/viewModel/contact_info_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:link_up/features/profile/utils/profile_view_helpers.dart'; 
import 'package:link_up/features/profile/model/profile_model.dart'; 
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart';



class ContactInfoPage extends ConsumerStatefulWidget {
  final UserProfile userProfile; 

  const ContactInfoPage({super.key, required this.userProfile});

  @override
  ConsumerState<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends ConsumerState<ContactInfoPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() => ref
        .read(contactInfoViewModelProvider.notifier)
        .fetchInitialData(widget.userProfile.isMe ? null : widget.userProfile.firstName));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(contactInfoViewModelProvider);
    final bool isMyProfile = widget.userProfile.isMe; 

    ContactInfoModel? contactInfo;
    bool isLoading = true; 

    if (state is EditContactInfoLoaded) {
      contactInfo = state.contactInfo;
      isLoading = false;
    } else if (state is EditContactInfoLoading || state is EditContactInfoInitial) {
      isLoading = true;
    } else if (state is EditContactInfoError) {
      isLoading = false;
      print("Error loading contact info: ${state.message}");
    } else if (state is EditContactInfoSaving || state is EditContactInfoSuccess) {
        isLoading = false;
        if (state is EditContactInfoSaving) {
            contactInfo = state.contactInfo;
        } else {

             Future.microtask(() => ref
                .read(contactInfoViewModelProvider.notifier)
                .fetchInitialData(widget.userProfile.isMe ? null : widget.userProfile.firstName)); 
        }
    }


    final String profileUrl = "https://www.linkedin.com/in/${widget.userProfile.firstName.toLowerCase()}-${widget.userProfile.lastName.toLowerCase()}-${widget.userProfile.firstName}";  

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(
          'Contact',
          style: TextStyles.font18_700Weight.copyWith(
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
        ),
        actions: [
          if (isMyProfile) 
            IconButton(
              icon: Icon(Icons.edit,
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  size: 20.sp),
              tooltip: "Edit Contact Info",
              onPressed: () => GoRouter.of(context).push('/edit_contact_info'),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              child: Container(
                 padding: EdgeInsets.all(16.w),
                 decoration: BoxDecoration(
                   color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                   borderRadius: BorderRadius.circular(8.r),
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactItem(
                      context: context,
                      isDarkMode: isDarkMode,
                      iconData: Icons.person_outline,
                      label: 'Your Profile',
                      value: profileUrl,
                      isUrl: true,
                    ),
                    _buildDivider(isDarkMode),
                    _buildContactItem(
                      context: context,
                      isDarkMode: isDarkMode,
                      iconData: Icons.email_outlined,
                      label: 'Email',
                      value: InternalEndPoints.email, 
                      isUrl: false, 
                    ),
                    if (contactInfo != null) ...[
                       if (contactInfo.website != null && contactInfo.website!.isNotEmpty) ...[
                           _buildDivider(isDarkMode),
                          _buildContactItem(
                            context: context,
                            isDarkMode: isDarkMode,
                            iconData: Icons.language,
                            label: 'Website',
                            value: contactInfo.website!,
                            isUrl: true,
                           ),
                       ],
                       if (contactInfo.phoneNumber != null && contactInfo.phoneNumber!.isNotEmpty) ...[
                           _buildDivider(isDarkMode),
                           _buildContactItem(
                             context: context,
                             isDarkMode: isDarkMode,
                             iconData: Icons.phone_outlined,
                             label: '${contactInfo.phoneType ?? 'Phone'} (${contactInfo.countryCode ?? ''})', 
                             value: contactInfo.phoneNumber!,
                             isUrl: false, 
                           ),
                       ],
                       if (contactInfo.address != null && contactInfo.address!.isNotEmpty) ...[
                           _buildDivider(isDarkMode),
                           _buildContactItem(
                             context: context,
                             isDarkMode: isDarkMode,
                             iconData: Icons.location_on_outlined,
                             label: 'Address',
                             value: contactInfo.address!,
                             isUrl: false,
                           ),
                       ],
                       if (contactInfo.birthday != null) ...[
                          _buildDivider(isDarkMode),
                           _buildContactItem(
                             context: context,
                             isDarkMode: isDarkMode,
                             iconData: Icons.cake_outlined,
                             label: 'Birthday',
                             value: DateFormat('MMMM d').format(contactInfo.birthday!), 
                             isUrl: false,
                           ),
                       ],
                    ] else if (!isLoading) ...[
                       _buildDivider(isDarkMode),
                       Padding(
                         padding: EdgeInsets.symmetric(vertical: 10.h),
                         child: Text("No additional contact info available.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey)),
                       )
                    ]
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactItem({
      required BuildContext context,
      required bool isDarkMode,
      IconData? iconData,
      Widget? iconWidget, 
      required String label,
      required String value,
      bool isUrl = false}) {
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final linkColor = AppColors.lightBlue; 

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w, 
            child: iconWidget ?? (iconData != null
                ? Icon(iconData, color: textColor, size: 24.sp)
                : SizedBox(width: 24.sp)), 
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                ),
                SizedBox(height: 4.h),
                InkWell(
                onTap: () {
                  if (isUrl) {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard: $value'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.lightGreen, 
                      ),
                    );
                  }

                },child: Text(
                    value,
                    style: TextStyles.font14_500Weight.copyWith(
                      color: isUrl ? linkColor : textColor,
                      decoration: isUrl ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: isUrl ? linkColor : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1.h,
      thickness: 0.5,
      color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3),
    );
  }
}