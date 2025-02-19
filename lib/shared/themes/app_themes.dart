// The font and colors for each of the themes of the app

import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/chip_styles.dart';
import 'package:link_up/shared/themes/colors.dart';

class AppThemes {
  AppThemes._();

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Open Sans',
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightBackground,
      primary: AppColors.lightMain,
      secondary: AppColors.lightBlue,
    ),
    chipTheme: ChipStyle.lightChip,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkBackground,
      primary: AppColors.darkMain,
      secondary: AppColors.darkBlue,
    ),
    chipTheme: ChipStyle.darkChip,
  );
}
