import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

// Need to be revised but for the outlined and text buttons

class LinkUpButtonStyles {
  ElevatedButtonThemeData lightElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: profileOpenToLight(),
    );
  }

  ElevatedButtonThemeData darkElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: profileOpenToDark(),
    );
  }

  OutlinedButtonThemeData lightOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: profileOpenToLight(),
    );
  }

  OutlinedButtonThemeData darkOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: profileOpenToDark(),
    );
  }

  TextButtonThemeData lightTextButtonTheme() {
    return TextButtonThemeData(
      style: lightTextButtonStyle(),
    );
  }

  TextButtonThemeData darkTextButtonTheme() {
    return TextButtonThemeData(
      style: darkTextButtonStyle(),
    );
  }

  ButtonStyle lightTextButtonStyle({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font13_700Weight;

    return ButtonStyle(
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      textStyle: WidgetStateProperty.all(textStyle),
      foregroundColor: WidgetStateProperty.all(AppColors.lightBlue),
    );
  }

  ButtonStyle darkTextButtonStyle({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font13_700Weight;

    return ButtonStyle(
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      textStyle: WidgetStateProperty.all(textStyle),
      foregroundColor: WidgetStateProperty.all(AppColors.darkBlue),
    );
  }

  ButtonStyle profileOpenToLight({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font13_700Weight;

    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.lightMain,
      backgroundColor: AppColors.lightBlue,
      elevation: elevation,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AppColors.lightBlue,
          width: 1,
        ),
      ),
      textStyle: textStyle,
    );
  }

  ButtonStyle profileOpenToDark({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font13_700Weight;

    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.darkMain,
      backgroundColor: AppColors.darkBlue,
      elevation: elevation,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AppColors.darkBlue,
          width: 1,
        ),
      ),
      textStyle: textStyle,
    );
  }

  ButtonStyle myNetworkScreenConnectLight({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font15_700Weight;

    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.lightBlue,
      backgroundColor: AppColors.lightMain,
      elevation: elevation,
      padding: padding,
      minimumSize: Size(double.infinity, 5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AppColors.lightBlue,
          width: 1.0,
        ),
      ),
      textStyle: textStyle,
    );
  }

  ButtonStyle myNetworkScreenConnectLightPressed({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font15_700Weight;

    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.lightGrey,
      backgroundColor: AppColors.lightMain,
      elevation: elevation,
      padding: padding,
      minimumSize: Size(double.infinity, 5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AppColors.lightGrey,
          width: 1.0,
        ),
      ),
      textStyle: textStyle,
    );
  }

  ButtonStyle myNetworkScreenConnectDark({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font15_700Weight;

    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.darkBlue,
      backgroundColor: AppColors.darkMain,
      elevation: elevation,
      padding: padding,
      minimumSize: Size(double.infinity, 5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AppColors.darkBlue,
          width: 1.0,
        ),
      ),
      textStyle: textStyle,
    );
  }

  ButtonStyle myNetworkScreenConnectDarkPressed({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font15_700Weight;

    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.darkGrey,
      backgroundColor: AppColors.darkMain,
      elevation: elevation,
      padding: padding,
      minimumSize: Size(double.infinity, 5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AppColors.darkGrey,
          width: 1.0,
        ),
      ),
      textStyle: textStyle,
    );
  }

  // Profile buttons
  // Light Theme Button Styles
  ButtonStyle wideBlueElevatedButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  ButtonStyle circularButton() {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.lightTextColor, width: 1.2),
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
    );
  }

  ButtonStyle blueOutlinedButton() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.lightMain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      side: BorderSide(color: AppColors.lightBlue, width: 1.2),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Dark Theme Button Styles
  ButtonStyle wideBlueElevatedButtonDark() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  ButtonStyle circularButtonDark() {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.darkTextColor, width: 1.2),
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
    );
  }

  ButtonStyle blueOutlinedButtonDark() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.darkMain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      side: BorderSide(color: AppColors.darkBlue, width: 1.2),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  ButtonStyle jobsPreferencesLight({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font13_700Weight;

    return ButtonStyle(
      // foregroundColor: WidgetStateProperty.all(AppColors.lightMain),
      backgroundColor: WidgetStateProperty.all(AppColors.lightMain),
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: AppColors.lightGrey,
            width: 0.5,
          ),
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
    );
  }

  ButtonStyle jobsPreferencesDark({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    borderRadius ??= BorderRadius.all(Radius.circular(20));
    textStyle ??= TextStyles.font13_700Weight;

    return ButtonStyle(
      // foregroundColor: WidgetStateProperty.all(AppColors.lightMain),
      backgroundColor: WidgetStateProperty.all(AppColors.darkMain),
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: AppColors.darkGrey,
            width: 0.5,
          ),
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
    );
  }
}
