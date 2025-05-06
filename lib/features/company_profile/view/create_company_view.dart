import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:link_up/features/company_profile/state/company_profile_state.dart';
import 'package:link_up/features/company_profile/viewModel/company_profile_view_model.dart';
import 'package:link_up/features/company_profile/widgets/company_logo_picker.dart';
import 'package:link_up/features/company_profile/widgets/create_company_widget.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class CreateCompanyProfilePage extends ConsumerStatefulWidget {
  const CreateCompanyProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCompanyProfilePage> createState() => _CreateCompanyProfilePageState();
}

class _CreateCompanyProfilePageState extends ConsumerState<CreateCompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _formSubmitted = false;
  final List<String> _industries = [
    'Information Technology', 'Healthcare', 'Finance', 'Education',
    'Manufacturing', 'Retail', 'Transportation', 'Media', 'Construction', 'Other'
  ];
  final List<String> _companySizes = [
    '1-10 employees', '11-50 employees', '51-200 employees', '201-500 employees',
    '501-1000 employees', '1001-5000 employees', '5001-10000 employees', '10001+ employees'
  ];
  final List<String> _companyTypes = [
    'Private company', 'Public company', 'Government agency', 'Nonprofit', 'Partnership'
  ];

  @override
  void initState() {
    super.initState();

  }

  void _submitForm() {
    setState(() { 
      _formSubmitted = true; 
    });
    if (_formKey.currentState!.validate()) {
      ref.read(companyProfileViewModelProvider.notifier).createCompanyProfile();
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProfileViewModelProvider);
    final viewModel = ref.read(companyProfileViewModelProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ref.listen<CompanyProfileState>(companyProfileViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
             context.pop(); 
             viewModel.resetState(); 
          }
        });
      } else if (next.isError && next.errorMessage != null) {
          if (previous?.errorMessage != next.errorMessage) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                   content: Text('Error: ${next.errorMessage}'),
                   backgroundColor: Colors.red,
                ),
             );
          }
       }
    });


    return Scaffold(
      appBar: AppBar(
         backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
         elevation: 1,
         leading: IconButton(
           icon: Icon(Icons.arrow_back, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
           onPressed: () => context.pop(),
         ),
         title: Text('Create Company', style: TextStyles.font18_700Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
      ),
      body: SafeArea(
        child: state.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Company Profile',
                          style: TextStyles.font20_700Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.lightMain
                                : AppColors.darkMain,
                          ),
                        ),
                        SizedBox(height: 24.h),

                      
                        CompanyFormField(
                          label: 'Company Name *',
                          hintText: 'Enter company name',
                          controller: viewModel.nameController,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                            return 'Please enter company name';
                            }
                             if (value.length > 50) { 
                               return 'Name Can not exceed 50 characters';
                             }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        CompanyFormField(
                          label: 'Website',
                          hintText: 'https://www.example.com',
                          controller: viewModel.websiteController,
                          keyboardType: TextInputType.url,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; 
                            }
                            final trimmedValue = value.trim();
                            final uri = Uri.tryParse(trimmedValue);
                            final bool isValidUrl = uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
                            if (!isValidUrl) {
                              return 'Please enter a valid website URL (e.g., https://www.example.com)';
                            }
                            return null; 
                          },
                        ),
                        SizedBox(height: 16.h),

                        CompanyLogoPicker(
                          isDarkMode: isDarkMode,
                          currentLogoUrl: viewModel.logoController.text,
                          onLogoSelected: (String logoUrl) {
                              viewModel.setLogoUrl(logoUrl); 
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Description - Use ViewModel's controller
                        CompanyFormField(
                          label: 'Company Description *',
                          hintText: 'Describe your company',
                          controller: viewModel.descriptionController,
                          isMultiline: true,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter company description';
                            }
                             if (value.length < 20) { 
                               return 'Description must be at least 20 characters';
                             }
                             if (value.length > 500) { 
                               return 'Description can not exceed 500 characters';
                             }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Industry dropdown - Use ViewModel's value and setter
                        CompanyDropdownField(
                          label: 'Industry *',
                          value: viewModel.selectedIndustry,
                          items: _industries,
                          onChanged: (value) {
                            if (value != null && _industries.contains(value)) {
                               viewModel.setSelectedIndustry(value);
                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 16.h),

                        // --- Location Picker ---
                        Text(
                          'Location *',
                          style: TextStyles.font16_600Weight.copyWith(
                            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CountryStateCityPicker(
                          country: viewModel.countryController,
                          state: viewModel.stateController,
                          city: viewModel.cityController,
                          textFieldDecoration: InputDecoration(
                             filled: true,
                             fillColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                             suffixIcon: Icon(Icons.arrow_drop_down, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(8.r),
                               borderSide: BorderSide.none, 
                             ),
                             contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              hintStyle: TextStyle(color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
                          ),
                          dialogColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                          

                        ),
                         Padding(
                           padding: const EdgeInsets.only(top: 4.0),
                           child: ValueListenableBuilder<TextEditingValue>(
                             valueListenable: viewModel.countryController,
                             builder: (context, value, child) {
                             if (value.text.trim().isEmpty && _formSubmitted) { // <--- MODIFIED CONDITION
                                 return Text(
                                   'Please select a country',
                                   style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.sp),
                                 );
                               }
                               return const SizedBox.shrink();
                             },
                           ),
                         ),

                        SizedBox(height: 16.h),

                        CompanyDropdownField(
                          label: 'Company Size',
                          value: viewModel.selectedSize,
                          items: _companySizes,
                          onChanged: (value) {
                            if (value != null && _companySizes.contains(value)) {
                               viewModel.setSelectedSize(value);
                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 16.h),

                        CompanyDropdownField(
                          label: 'Company Type',
                          value: viewModel.selectedType,
                          items: _companyTypes,
                          onChanged: (value) {
                            if (value != null && _companyTypes.contains(value)) {
                               viewModel.setSelectedType(value);
                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 32.h),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _submitForm, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: state.isLoading 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Create Company Profile',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        if (state.isError && state.errorMessage != null) ...[
                           SizedBox(height: 16.h),
                           Container(
                             width: double.infinity,
                             padding: EdgeInsets.all(12.w),
                             decoration: BoxDecoration(
                               color: Colors.red.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8.r),
                               border: Border.all(color: Colors.red),
                             ),
                             child: Text(
                               state.errorMessage!,
                               style: TextStyle(color: Colors.red, fontSize: 14.sp),
                             ),
                           ),
                        ],
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}