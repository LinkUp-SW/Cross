// The font and colors for each of the themes of the app

import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/chip_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class AppThemes {
  AppThemes._();

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Open Sans',
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightBackground,
      primary: AppColors.lightMain,
      secondary: AppColors.lightBlue,
    ),
    chipTheme: ChipStyle.lightChip,
    cardTheme: const CardTheme(color: AppColors.lightMain),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          iconColor: WidgetStateProperty.all(AppColors.lightSecondaryText)),
    ),
    elevatedButtonTheme: LinkUpButtonStyles().lightElevatedButtonTheme(),
    outlinedButtonTheme: LinkUpButtonStyles().lightOutlinedButtonTheme(),
    textButtonTheme: LinkUpButtonStyles().lightTextButtonTheme(),
    searchViewTheme: SearchViewThemeData(
      backgroundColor: AppColors.lightMain,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.lightBackground),
      elevation: WidgetStateProperty.all(0.0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightMain,
      elevation: 0.0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.lightTextColor,
      unselectedItemColor: AppColors.lightSecondaryText,
      selectedLabelStyle: TextStyles.font11_700Weight,
      unselectedLabelStyle: TextStyles.font11_400Weight,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: const IconThemeData(
        color: AppColors.lightTextColor,
        size: 24,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppColors.lightSecondaryText,
        size: 24,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Open Sans',
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkBackground,
      primary: AppColors.darkMain,
      secondary: AppColors.darkBlue,
    ),
    chipTheme: ChipStyle.darkChip,
    cardTheme: const CardTheme(color: AppColors.darkMain),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          iconColor: WidgetStateProperty.all(AppColors.darkTextColor)),
    ),
    elevatedButtonTheme: LinkUpButtonStyles().darkElevatedButtonTheme(),
    outlinedButtonTheme: LinkUpButtonStyles().darkOutlinedButtonTheme(),
    textButtonTheme: LinkUpButtonStyles().darkTextButtonTheme(),
    searchViewTheme: SearchViewThemeData(
      backgroundColor: AppColors.darkMain,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.darkBackground),
      elevation: WidgetStateProperty.all(0.0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
  );
}
