// lib/features/company/widgets/company_logo_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class CompanyLogoPicker extends StatefulWidget {
  final Function(String) onLogoSelected;
  final bool isDarkMode;
  final String? currentLogoUrl;

  const CompanyLogoPicker({
    Key? key,
    required this.onLogoSelected,
    required this.isDarkMode,
    this.currentLogoUrl,
  }) : super(key: key);

  @override
  State<CompanyLogoPicker> createState() => _CompanyLogoPickerState();
}

class _CompanyLogoPickerState extends State<CompanyLogoPicker> {
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUploading = true;
        });

        // Here you would typically upload the image to your server/storage
        // and get back a URL. For now, we'll simulate this with a delay.
        await Future.delayed(const Duration(seconds: 2));
        
        // Pass the URL (or path for now) to the parent
        widget.onLogoSelected(_selectedImage!.path);
        
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Select Image Source',
          style: TextStyle(
            color: widget.isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: widget.isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(
                  color: widget.isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: widget.isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
              ),
              title: Text(
                'Camera',
                style: TextStyle(
                  color: widget.isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Logo',
          style: TextStyles.font16_600Weight.copyWith(
            color: widget.isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: _isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isDarkMode ? Colors.white : Colors.blue,
                      ),
                    ),
                  )
                : _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: 120.w,
                          height: 120.h,
                        ),
                      )
                    : widget.currentLogoUrl != null && widget.currentLogoUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              widget.currentLogoUrl!,
                              fit: BoxFit.cover,
                              width: 120.w,
                              height: 120.h,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.isDarkMode ? Colors.white : Colors.blue,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : _buildPlaceholder(),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap to select a logo image',
          style: TextStyles.font12_400Weight.copyWith(
            color: widget.isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 40.sp,
            color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            'Add Logo',
            style: TextStyle(
              fontSize: 12.sp,
              color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}