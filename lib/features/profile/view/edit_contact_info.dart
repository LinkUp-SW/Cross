
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; 
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/state/contact_info_state.dart';
import 'package:link_up/features/profile/viewModel/contact_info_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/features/profile/widgets/subpages_dropdown.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';

class EditContactInfo extends ConsumerStatefulWidget {
  const EditContactInfo({super.key});

  @override
  ConsumerState<EditContactInfo> createState() => _EditContactInfoState();
}

class _EditContactInfoState extends ConsumerState<EditContactInfo> {
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _birthdayFocusNode = FocusNode();
  final FocusNode _websiteFocusNode = FocusNode();

  String? _initialCountryCode;

  @override
  void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
          final state = ref.read(contactInfoViewModelProvider);
          if (state is EditContactInfoLoaded) {
             setState(() {
                _initialCountryCode = state.contactInfo.countryCode;
             });
          } else if (state is EditContactInfoError && state.previousContactInfo != null) {
             setState(() {
                _initialCountryCode = state.previousContactInfo!.countryCode;
             });
          }
          _initialCountryCode ??= 'EG';
      });
  }


  @override
  void dispose() {
    _addressFocusNode.dispose();
    _birthdayFocusNode.dispose();
    _websiteFocusNode.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Copied!",
          style: TextStyles.font14_400Weight.copyWith(
            color: AppColors.lightMain,
          ),
        ),
        backgroundColor: AppColors.lightBlue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _selectBirthday(BuildContext context) async {
     final viewModel = ref.read(contactInfoViewModelProvider.notifier);
     final currentState = ref.read(contactInfoViewModelProvider);
     DateTime initialDate = DateTime.now();
     DateTime? currentBirthday;

      if (currentState is EditContactInfoLoaded) {
         currentBirthday = currentState.contactInfo.birthday;
      } else if (currentState is EditContactInfoSaving) {
         currentBirthday = currentState.contactInfo.birthday;
      } else if (currentState is EditContactInfoError && currentState.previousContactInfo != null) {
         currentBirthday = currentState.previousContactInfo!.birthday;
      }

     initialDate = currentBirthday ?? DateTime(DateTime.now().year - 20);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
       builder: (context, child) {
         final isDarkMode = Theme.of(context).brightness == Brightness.dark;
         return Theme(
           data: ThemeData(
             colorScheme: isDarkMode ? const ColorScheme.dark(
                 primary: AppColors.darkBlue,
                 onPrimary: AppColors.darkMain,
                 surface: AppColors.darkMain,
                 onSurface: AppColors.darkTextColor,
             ) : const ColorScheme.light(
                 primary: AppColors.lightBlue,
                 onPrimary: AppColors.lightMain,
                 surface: AppColors.lightMain,
                 onSurface: AppColors.lightTextColor,
             ),
              dialogBackgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
           ),
           child: child!,
         );
       },
    );
    if (picked != null) {
      viewModel.setBirthday(picked);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final state = ref.watch(contactInfoViewModelProvider);
    final viewModel = ref.read(contactInfoViewModelProvider.notifier);
    String? errorText;
     if (state is EditContactInfoError) {
        errorText = state.message;
     }
     ref.listen<EditContactInfoState>(contactInfoViewModelProvider, (previous, next) {
        if (previous is! EditContactInfoError && next is EditContactInfoError) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                       content: Text('Error: ${next.message}'),
                       backgroundColor: Colors.red,
                    ),
                 );
              }
           });
        } else if (previous is! EditContactInfoSuccess && next is EditContactInfoSuccess) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                         content: Text('Contact info saved successfully!'),
                         backgroundColor: Colors.green,
                      ),
                   );
                }
             });
        }
         if ((previous is EditContactInfoInitial || previous is EditContactInfoLoading) &&
             (next is EditContactInfoLoaded || (next is EditContactInfoError && next.previousContactInfo != null))) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                 final loadedState = next is EditContactInfoLoaded ? next : null;
                 final errorState = next is EditContactInfoError ? next : null;
                 final newCode = loadedState?.contactInfo.countryCode ?? errorState?.previousContactInfo?.countryCode;
                 setState(() {
                    _initialCountryCode = newCode ?? 'EG'; 
                 });
              }
           });
         }
     });

    TextEditingController phoneNumberController = viewModel.phoneNumberController;
    TextEditingController addressController = viewModel.addressController;
    TextEditingController birthdayController = viewModel.birthdayController;
    TextEditingController websiteController = viewModel.websiteController;
    String? selectedPhoneType = viewModel.selectedPhoneType; 

    final String profileUrl = InternalEndPoints.profileUrl.isNotEmpty
      ? InternalEndPoints.profileUrl
      : "https://www.linkedin.com/in/firstname-lastname-userid/";
    final String email = InternalEndPoints.email.isNotEmpty
       ? InternalEndPoints.email
       : "email@example.com";

    bool isLoading = state is EditContactInfoLoading;
    bool isSaving = state is EditContactInfoSaving;


     String? getErrorForField(String fieldName) {
        if (errorText == null) return null;
        if (errorText!.toLowerCase().contains(fieldName.toLowerCase()) || errorText!.toLowerCase().contains('url')) {
           return errorText;
        }
        return null;
     }
 
    String initialPhoneNumber = '';
    if (state is EditContactInfoLoaded) {
        initialPhoneNumber = state.contactInfo.phoneNumber ?? '';
    } else if (state is EditContactInfoError && state.previousContactInfo != null) {
        initialPhoneNumber = state.previousContactInfo!.phoneNumber ?? '';
    }


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Edit contact info",
              onClosePressed: () {
                GoRouter.of(context).pop();
              },
            ),
            Expanded(
              child: Container(
                color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
                 child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SubPagesIndicatesRequiredLabel(),
                            SizedBox(height: 10),

                             SubPagesFormLabel(label: "Profile URL"),
                             SizedBox(height: 2),
                             GestureDetector(
                               onTap: () => _copyToClipboard(context, profileUrl),
                               child: Row(
                                 children: [
                                   Expanded(
                                     child: Text(
                                       profileUrl,
                                       style: TextStyles.font14_400Weight.copyWith(
                                         color: AppColors.lightBlue,
                                         decoration: TextDecoration.underline,
                                       ),
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                   Icon(Icons.open_in_new, color: AppColors.lightBlue, size: 20),
                                 ],
                               ),
                             ),
                             SizedBox(height: 20),

                             SubPagesFormLabel(label: "Email"),
                             SizedBox(height: 2),
                             GestureDetector(
                               onTap: () => _copyToClipboard(context, email),
                               child: Row(
                                 children: [
                                   Expanded(
                                     child: Text(
                                       email,
                                       style: TextStyles.font14_400Weight.copyWith(
                                         color: AppColors.lightBlue,
                                         decoration: TextDecoration.underline,
                                       ),
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                   Icon(Icons.open_in_new, color: AppColors.lightBlue, size: 20),
                                 ],
                               ),
                             ),
                             SizedBox(height: 20),

                            SubPagesFormLabel(label: "Phone number"),
                            SizedBox(height: 2),
                            if (_initialCountryCode != null) 
                                IntlPhoneField(
                                   key: ValueKey(_initialCountryCode), 
                                   controller: phoneNumberController, 
                                   initialCountryCode: _initialCountryCode, 
                                   initialValue: initialPhoneNumber, 
                                   decoration: InputDecoration(
                                     labelText: 'Phone Number',
                                     border: UnderlineInputBorder(
                                       borderSide: BorderSide(color: AppColors.lightGrey),
                                     ),
                                      enabledBorder: UnderlineInputBorder(
                                         borderSide: BorderSide(color: AppColors.lightGrey),
                                       ),
                                       focusedBorder: UnderlineInputBorder(
                                         borderSide: BorderSide(color: AppColors.lightBlue),
                                       ),
                                   ),
                                   style: TextStyles.font14_400Weight.copyWith(
                                     color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                   ),
                                   dropdownTextStyle: TextStyles.font14_400Weight.copyWith(
                                      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                   ),
                                   enabled: !isSaving,
                                   onChanged: (phone) {
                                     viewModel.setPhoneNumber(phone.number, phone.countryISOCode);
                                   },
                                  
                                ),
                            if (_initialCountryCode == null && !isLoading)
                                 Container(height: 60, alignment: Alignment.center, child: Text("Loading phone info...")),
                             SizedBox(height: 20),


                            SubPagesFormLabel(label: "Phone type"),
                            SizedBox(height: 2),
                            SubPagesCustomDropdownFormField<String>(
                              value: selectedPhoneType,
                              hintText: "Please select",
                              items: const [
                                DropdownMenuItem(value: "mobile", child: Text("Mobile")),
                                DropdownMenuItem(value: "home", child: Text("Home")),
                                DropdownMenuItem(value: "work", child: Text("Work")),
                              ],
                              onChanged: isSaving ? null : (value) => viewModel.setPhoneType(value),
                            ),
                            SizedBox(height: 20),

                            SubPagesFormLabel(label: "Address"),
                            SizedBox(height: 2),
                            SubPagesCustomTextField(
                              controller: addressController,
                              focusNode: _addressFocusNode,
                              enabled: !isSaving,
                              maxLines: null, 
                              maxLength: 220,
                            ),
                            SizedBox(height: 20),

                            SubPagesFormLabel(label: "Birthday"),
                            SizedBox(height: 2),
                             InkWell(
                                onTap: isSaving ? null : () => _selectBirthday(context),
                                child: AbsorbPointer(
                                  child: SubPagesCustomTextField(
                                      controller: birthdayController,
                                      hintText: "Select birthday",
                                      focusNode: _birthdayFocusNode,
                                      enabled: !isSaving,
                                      suffixIcon: Icon(
                                         Icons.calendar_today,
                                         color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                         size: 20,
                                      ),
                                  ),
                                ),
                             ),
                            SizedBox(height: 20),

                            SubPagesFormLabel(label: "Website"),
                            SizedBox(height: 2),
                                 TextFormField( // Changed to TextFormField
                               controller: websiteController,
                               focusNode: _websiteFocusNode,
                               enabled: !isSaving,
                               keyboardType: TextInputType.url,
                               decoration: InputDecoration(
                                   border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGrey)),
                                   enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGrey)),
                                   focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightBlue)),
                                  errorText: getErrorForField("Website"), // Show validation error
                                   errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
                               ),
                                style: TextStyles.font14_400Weight.copyWith(
                                   color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                ),
                             ),
                            SizedBox(height: 20),
                          ],
                        ),
                    ),
                ),
            ),

            if (!isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () => viewModel.saveContactInfo(),
                     style: (isDarkMode
                           ? buttonStyles.wideBlueElevatedButtonDark()
                           : buttonStyles.wideBlueElevatedButton()
                     ).copyWith(minimumSize: MaterialStateProperty.all(Size.fromHeight(50))), 
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                         )
                        : Text(
                            "Save",
                            style: TextStyles.font15_500Weight.copyWith(
                              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}