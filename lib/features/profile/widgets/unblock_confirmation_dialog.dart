import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class UnblockConfirmationDialog extends ConsumerStatefulWidget {
  final String userName;

  const UnblockConfirmationDialog({super.key, required this.userName});

  @override
  ConsumerState<UnblockConfirmationDialog> createState() => _UnblockConfirmationDialogState();
}

class _UnblockConfirmationDialogState extends ConsumerState<UnblockConfirmationDialog> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; 
  final _formKey = GlobalKey<FormState>(); 

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
     if (_formKey.currentState!.validate()) {
       Navigator.of(context).pop(_passwordController.text);
     }
   }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final buttonColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBlue; 
    final buttonTextColor = Colors.white;

    return AlertDialog(
      backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Unblock ${widget.userName}',
            textAlign: TextAlign.center,
            style: TextStyles.font18_700Weight.copyWith(color: textColor),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close, color: secondaryTextColor, size: 20.sp),
              onPressed: () => Navigator.of(context).pop(null), 
              splashRadius: 20.r,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          )
        ],
      ),
      content: SingleChildScrollView( 
        child: Form(
           key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter your password to confirm unblocking.',
                style: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
              ),
              SizedBox(height: 15.h),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                autofocus: true,
                style: TextStyles.font14_400Weight.copyWith(color: textColor),
                cursorColor: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: secondaryTextColor,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                 validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null; 
                  },
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text('Confirm Unblock', style: TextStyles.font15_500Weight.copyWith(color: buttonTextColor)),
                ),
              ),
              SizedBox(height: 15.h),
              Center(
                child: Text(
                  "You won't be able to reblock this user for the next 48 hours.",
                  textAlign: TextAlign.center,
                  style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
    );
  }
}

Future<String?> showUnblockConfirmationDialog(BuildContext context, String userName) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext context) {
      return UnblockConfirmationDialog(userName: userName);
    },
  );
}