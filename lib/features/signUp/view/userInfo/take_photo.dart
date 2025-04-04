import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:link_up/features/signUp/state/image_picker_state.dart';
import 'package:link_up/features/signUp/viewModel/image_picker_provider.dart';

class TakePhoto extends ConsumerWidget {
  const TakePhoto({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePickerState = ref.watch(imagePickerProvider);
    final imagePickerNotifier = ref.read(imagePickerProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
                alignment: Alignment.topLeft,
                width: 100.w,
                height: 100.h,
                image: const AssetImage('assets/images/Logo.png')),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Adding a photo helps People Recognize you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),
                GestureDetector(
                  onTap: () => imagePickerNotifier.showImageSourceDialog(
                      context, imagePickerNotifier),
                  child: Container(
                    height: 200.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(100),
                      image: (imagePickerState is ImageSelectedState)
                          ? DecorationImage(
                              image:
                                  FileImage(File(imagePickerState.image.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (imagePickerState is ImageSelectedState)
                        ? null
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children:  [
                              Icon(Icons.camera_alt, size: 100),
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'Take Photo',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 220.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    context.push('/login');
                  },
                  child: (imagePickerState is ImageSelectedState)
                      ? const Text('Next', style: TextStyle(fontSize: 20))
                      : const Text('Skip', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
