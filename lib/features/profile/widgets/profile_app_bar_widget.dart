import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/text_styles.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ProfileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(top: 13.h), 
        child: Row(
          children: [
     
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black54, size: 28.sp),
              onPressed: () => Navigator.pop(context),
            ),

     
            Expanded(
              child: Container(
                height: 36.h, 
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FC), 
                  borderRadius: BorderRadius.circular(6.r), 
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black54, size: 22.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        onChanged: (value) =>
                            ref.read(searchQueryProvider.notifier).state = value,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyles.font15_400Weight
                              .copyWith(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              icon: Icon(Icons.settings, color: Colors.black54, size: 28.sp),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
