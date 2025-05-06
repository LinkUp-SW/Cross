// lib/features/company/widgets/company_form_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class CompanyFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool isMultiline;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isDarkMode;

  const CompanyFormField({
    Key? key,
    required this.label,
    this.hintText,
    required this.controller,
    this.isMultiline = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.font16_600Weight.copyWith(
            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
            ),
            fillColor: isDarkMode ?AppColors.darkMain : AppColors.lightMain,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: isMultiline ? 16.h : 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

class CompanyDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isDarkMode;

  const CompanyDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.font16_600Weight.copyWith(
            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              style: TextStyle(
                color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}