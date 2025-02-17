

import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';

class ChipStyle {
  ChipStyle._();

  static ChipThemeData lightChip = const ChipThemeData(
    showCheckmark: false,
    backgroundColor: Colors.transparent,
    selectedColor: AppColors.lightGreen,
    shape:RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    labelStyle: TextStyle(color: AppColors.lightTextColor),
    secondaryLabelStyle: TextStyle(color: AppColors.lightMain),
    pressElevation: 1,
    elevation: 3
    );

  static ChipThemeData darkChip = const ChipThemeData(
    showCheckmark: false,
    backgroundColor: Colors.transparent,
    selectedColor: AppColors.darkGreen,
    shape:RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    labelStyle: TextStyle(color: AppColors.lightMain),
    secondaryLabelStyle: TextStyle(color: AppColors.lightTextColor),
    pressElevation: 1,
    elevation: 3
    );
}