import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesCustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? labelText;

  const SubPagesCustomDropdownFormField({
    super.key,
    this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(
        hintText,
        style: TextStyles.font14_400Weight.copyWith(
          color: AppColors.lightGrey,
        ),
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      ),
      style: TextStyles.font14_400Weight.copyWith(
        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightBlue),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}