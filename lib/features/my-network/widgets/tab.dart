import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';

class CustomTab extends ConsumerWidget {
  final String title;
  const CustomTab({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.lightGrey, width: 0.5),
        ),
      ),
      child: Tab(text: title),
    );
  }
}
