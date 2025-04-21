import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesCustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int? maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final FocusNode? focusNode; // Added FocusNode parameter
  final bool? enabled;       // Added enabled parameter

  const SubPagesCustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines,
    this.suffixIcon,
    this.onTap,
    this.focusNode, 
    this.enabled,   
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,    
      style: TextStyles.font14_400Weight.copyWith(
        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      ),
      cursorColor: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue, 
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyles.font14_400Weight.copyWith(
          color: AppColors.lightGrey,
        ),
        suffixIcon: suffixIcon,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightBlue),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
      ),
      onTap: onTap,
    );
  }
}