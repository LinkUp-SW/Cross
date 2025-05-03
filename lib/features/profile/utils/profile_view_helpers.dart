import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago; 

import 'dart:developer';
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  return timeago.format(now.subtract(difference));
}
String formatDate(DateTime? date) {
  if (date == null) return '';
  try {
    return DateFormat('MMM yyyy').format(date);
  } catch (e) {
    log("Error formatting date '$date': $e");
    return date.toIso8601String().split('T').first;
  }
}

String formatDateRange(DateTime? startDate, DateTime? endDate, {bool isCurrent = false, bool doesNotExist = false}) {
  final startFormatted = formatDate(startDate);
  if (startFormatted.isEmpty) return 'Date missing';

  if (isCurrent || (endDate == null && !doesNotExist)) {
    return '$startFormatted - Present';
  } else if (doesNotExist) {
    return 'Issued $startFormatted${endDate == null ? ' · No Expiration' : ''}';
  } else {
    final endFormatted = formatDate(endDate);
    if (endFormatted.isNotEmpty) {
      return '$startFormatted - $endFormatted';
    } else {
      return startFormatted;
    }
  }
}

Widget buildSkillsRowWidget(List<String> skills, bool isDarkMode) {
  if (skills.isEmpty) {
    return const SizedBox.shrink();
  }
  final displayedSkills = skills.take(5).toList();
  String skillsText = displayedSkills.join(' • ');
  final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
  final secondaryTextColor = AppColors.lightGrey;

  return Padding(
    padding: EdgeInsets.only(top: 6.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.star_outline, size: 14.sp, color: secondaryTextColor),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Skills: $skillsText',
            style: TextStyles.font13_500Weight.copyWith(color: textColor),
          ),
        ),
      ],
    ),
  );
}

Future<void> launchUrlHelper(BuildContext context, String? urlString) async {
  if (urlString == null || urlString.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No URL provided.'), backgroundColor: Colors.orange)
    );
    return;
  }
  String urlToLaunch = urlString.trim();
  if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
    urlToLaunch = 'https://$urlToLaunch';
  }
  final Uri? url = Uri.tryParse(urlToLaunch);
  if (url == null) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL format: $urlString'), backgroundColor: Colors.red));
    return;
  }
  if (await canLaunchUrl(url)) {
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch URL: $e'), backgroundColor: Colors.red));
    }
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url'), backgroundColor: Colors.orange));
  }
}