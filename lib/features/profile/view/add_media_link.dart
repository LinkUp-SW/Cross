
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart'; 
import 'package:link_up/features/profile/widgets/subpages_indication.dart'; 

class AddMediaLinkPage extends ConsumerStatefulWidget {
  const AddMediaLinkPage({super.key});

  @override
  ConsumerState<AddMediaLinkPage> createState() => _AddMediaLinkPageState();
}

class _AddMediaLinkPageState extends ConsumerState<AddMediaLinkPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _canAdd = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_validateForm);
    _titleController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _urlController.removeListener(_validateForm);
    _titleController.removeListener(_validateForm);
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final urlValid = _validateUrl(_urlController.text) == null;
    final titleValid = _titleController.text.trim().isNotEmpty;
    setState(() {
      _canAdd = urlValid && titleValid;
    });
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "URL is required.";
    }
 
    final urlRegExp = RegExp(
      r"^(https?:\/\/)?(www\.)?([\w-]+\.)+[\w-]+(\/[\w-.\/?%&=]*)?$",
      caseSensitive: false,
    );
    if (!urlRegExp.hasMatch(value.trim())) {
      return "Please enter a valid URL.";
    }
    return null;
  }

  void _addLink() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'media': _urlController.text.trim(), 
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };
      context.pop(result); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final appBarColor = isDarkMode ? AppColors.darkMain : AppColors.lightMain;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final fieldUnderlineColor = AppColors.lightGrey;
    final fieldFocusedUnderlineColor = AppColors.lightBlue;
    final cursorColor = isDarkMode ? AppColors.darkBlue : AppColors.lightBlue;
    final addButtonColor = isDarkMode ? AppColors.darkBlue : AppColors.lightBlue;
    final addButtonTextColor = isDarkMode ? AppColors.darkMain : AppColors.lightMain;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add a link',
          style: TextStyles.font18_700Weight.copyWith(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: _canAdd ? _addLink : null,
            child: Text(
              'Add',
              style: TextStyles.font16_600Weight.copyWith(
                color: _canAdd
                    ? addButtonColor
                    : secondaryTextColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SubPagesIndicatesRequiredLabel(),
              SizedBox(height: 15.h),

              // --- URL Field ---
              SubPagesFormLabel(label: "URL", isRequired: true),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _urlController,
                autofocus: true,
                keyboardType: TextInputType.url,
                style: TextStyles.font14_400Weight.copyWith(color: textColor),
                cursorColor: cursorColor,
                decoration: InputDecoration(
                  hintText: "Paste or type a link",
                  hintStyle: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: fieldUnderlineColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: fieldUnderlineColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: fieldFocusedUnderlineColor)),
                ),
                validator: _validateUrl,
              ),
              SizedBox(height: 25.h),

              // --- Title Field ---
              SubPagesFormLabel(label: "Title", isRequired: true),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _titleController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyles.font14_400Weight.copyWith(color: textColor),
                cursorColor: cursorColor,
                maxLength: 100, 
                decoration: InputDecoration(
                  hintText: "Title for your link",
                  hintStyle: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: fieldUnderlineColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: fieldUnderlineColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: fieldFocusedUnderlineColor)),
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 8.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${_titleController.text.length} / 100",
                    style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                  ),
                ),
              ),
              SizedBox(height: 25.h),

              // --- Description Field ---
              SubPagesFormLabel(label: "Description (Optional)"),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyles.font14_400Weight.copyWith(color: textColor),
                cursorColor: cursorColor,
                maxLines: null,
                maxLength: 500, 
                decoration: InputDecoration(
                  hintText: "Add a short description (optional)",
                  hintStyle: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: fieldUnderlineColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: fieldUnderlineColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: fieldFocusedUnderlineColor)),
                  counterText: "",
                ),
              ),
               Padding(
                padding: EdgeInsets.only(top: 4.h, right: 8.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${_descriptionController.text.length} / 500",
                    style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}