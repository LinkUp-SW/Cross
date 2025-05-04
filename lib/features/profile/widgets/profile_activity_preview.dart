import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart'; 
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/features/profile/widgets/section_widget.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';

enum ActivityFilter { posts }

class ProfileActivityPreview extends StatefulWidget {
  final String userId;
  final String userName;
  final int numberOfConnections;
  final bool isMyProfile;
  

  const ProfileActivityPreview({
    required this.userId,
    required this.userName,
    required this.numberOfConnections,
    required this.isMyProfile,
    super.key,
  });

  @override
  State<ProfileActivityPreview> createState() => _ProfileActivityPreviewState();
}

class _ProfileActivityPreviewState extends State<ProfileActivityPreview> {
  List<PostModel> _previewPosts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  ActivityFilter _selectedFilter = ActivityFilter.posts;
  final int _previewLimit = 1;

  @override
  void initState() {
    super.initState();
    _fetchPreviewPosts();
  }

  Future<void> _fetchPreviewPosts() async {
    if (_selectedFilter != ActivityFilter.posts) {
       setState(() {
          _isLoading = false;
          _hasError = false;
          _previewPosts = [];
       });
       return;
    }
     if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    log("ProfileActivityPreview: Fetching preview posts for user ${widget.userId}");
    try {
      final fetchedData = await getUserPosts(0, widget.userId);
      if (mounted) {
        setState(() {
          _previewPosts = (fetchedData.first as List<PostModel>).take(_previewLimit).toList();
          _isLoading = false;
          log("ProfileActivityPreview: Fetched ${_previewPosts.length} posts for preview.");
        });
      }
    } catch (error, stackTrace) {
      log('ProfileActivityPreview: Error fetching preview posts: $error', stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = error.toString();
          _previewPosts = [];
        });
      }
    }
  }


  Widget _buildFilterChips(bool isDarkMode) {
     return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: ActivityFilter.values.map((filter) {
          bool isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                filter.name[0].toUpperCase() + filter.name.substring(1), 
                 style: TextStyles.font14_600Weight.copyWith(
                  color: isSelected
                    ? (isDarkMode ? AppColors.darkMain : AppColors.lightMain)
                    : (isDarkMode ? AppColors.darkGreen : AppColors.lightGreen)  
              )),
              selected: isSelected,
              onSelected: (selected) {
                 if (selected) {
                   setState(() {
                     _selectedFilter = filter;
                     _fetchPreviewPosts();
                   });
                 }
              },
              backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              selectedColor: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent 
                      : (isDarkMode ? AppColors.darkBlue : AppColors.lightBlue), 
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
               labelPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
               padding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sectionTextColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final followerTextColor = isDarkMode ? AppColors.darkGrey : AppColors.lightGrey;
    final buttonStyles = LinkUpButtonStyles(); 
    return Container(
       width: double.infinity,
       padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
       margin: EdgeInsets.only(top: 10.h),
       decoration: BoxDecoration(
         color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
         borderRadius: BorderRadius.circular(8.r),
       ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Activity", 
                    style: TextStyles.font18_600Weight.copyWith(
                      color: sectionTextColor
                    )
                  ),
                  Text(
                    "${widget.numberOfConnections} Connections",
                    style: TextStyles.font14_400Weight.copyWith(
                      color: followerTextColor
                    ),
                  ),
                ],
              ),
              if (widget.isMyProfile)
              OutlinedButton(
                onPressed: () {
                  context.push('/writePost');
                },
                style: isDarkMode 
                  ? buttonStyles.blueOutlinedButtonDark()
                  : buttonStyles.blueOutlinedButton(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 16.sp,
                      color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Create Post",
                      style: TextStyles.font14_500Weight.copyWith(
                        color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          _buildFilterChips(isDarkMode),
          _buildContent(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load activity.\nError: ${_errorMessage?.split(':').last.trim()}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: _fetchPreviewPosts,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    Widget contentToShow;
    String emptyMessage = "No activity to show.";

    switch (_selectedFilter) {
      case ActivityFilter.posts:
        if (_previewPosts.isEmpty) {
          emptyMessage = "No posts to show.";
          contentToShow = Center(
            child: Text(
              emptyMessage,
              style: TextStyles.font14_400Weight.copyWith(
                color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey
              ),
            ),
          );
        } else {
          contentToShow = ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _previewPosts.length,
            itemBuilder: (context, index) {
              final post = _previewPosts[index];
              return GestureDetector(
                onTap: () {
                  log("ProfileActivityPreview: Tapped post preview, navigating to /userPosts");
                  context.push('/userPosts'); 
                },
                behavior: HitTestBehavior.opaque,
                child: IgnorePointer( 
                  ignoring: true,
                  child: Posts(
                    post: post,
                    inFeed: false,
                    showBottom: true,
                  ),
                ),
              );
            },
          );
        }
    }

    return Column(
      children: [
        contentToShow,
        SizedBox(height: 8.h),
        Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3)),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              log("ProfileActivityPreview: 'Show all' button pressed for filter: $_selectedFilter");
              
              context.push('/userPosts');
            },
            style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show all ${_selectedFilter.name}', style: TextStyles.font14_600Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward, size: 16.sp, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)
              ]
            )
          ),
        )
      ],
    );
  }
}