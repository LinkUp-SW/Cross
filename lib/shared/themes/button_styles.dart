import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      style: profileOpenToLight(),
    );
  }

  TextButtonThemeData darkTextButtonTheme() {
    return TextButtonThemeData(
      style: profileOpenToDark(),
    );
  }


  ButtonStyle profileOpenToLight({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h);
    borderRadius ??= BorderRadius.all(Radius.circular(20.r));
    textStyle ??= TextStyles.font13_700Weight;

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.lightMain),
      backgroundColor: WidgetStateProperty.all(AppColors.lightBlue),
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: AppColors.lightBlue,
            width: 1.w,
          ),
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
    );
  }

  ButtonStyle profileOpenToDark({
    double elevation = 0.0,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    padding ??= EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h);
    borderRadius ??= BorderRadius.all(Radius.circular(20.r));
    textStyle ??= TextStyles.font13_700Weight;

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.darkMain),
      backgroundColor: WidgetStateProperty.all(AppColors.darkBlue),
      elevation: WidgetStateProperty.all(elevation),
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: AppColors.darkBlue,
            width: 1.w,
          ),
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
    );
  }
}


// The rest of buttons styles should be exist here