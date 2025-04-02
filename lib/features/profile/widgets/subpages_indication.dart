import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesIndicatesRequiredLabel extends StatelessWidget {
  const SubPagesIndicatesRequiredLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Text(
      "* Indicates required",
      style: TextStyles.font13_400Weight.copyWith(
        color: AppColors.lightGrey,
      ),
    );
  }
}