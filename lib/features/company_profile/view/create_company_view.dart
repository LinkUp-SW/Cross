
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/company_profile/model/company_profile_model.dart';
import 'package:link_up/features/company_profile/viewModel/company_profile_view_model.dart';
import 'package:link_up/features/company_profile/widgets/company_logo_picker.dart';
import 'package:link_up/features/company_profile/widgets/create_company_widget.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';

import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class CreateCompanyProfilePage extends ConsumerStatefulWidget {
  const CreateCompanyProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCompanyProfilePage> createState() => _CreateCompanyProfilePageState();
}

class _CreateCompanyProfilePageState extends ConsumerState<CreateCompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  
  // Industry options
  final List<String> _industries = [
    'Information Technology',
    'Healthcare',
    'Finance',
    'Education',
    'Manufacturing',
    'Retail',
    'Transportation',
    'Media',
    'Construction',
    'Other'
  ];

  // Company size options
  final List<String> _companySizes = [
    '1-10 employees',
    '11-50 employees',
    '51-200 employees',
    '201-500 employees',
    '501-1000 employees',
    '1001-5000 employees',
    '5001-10000 employees',
    '10001+ employees'
  ];

  // Company type options
  final List<String> _companyTypes = [
    'Private company',
    'Public company',
    'Government agency',
    'Nonprofit',
    'Partnership',
  ];
  
  // Dropdown values - set them initially to the first item in each list
  late String _selectedIndustry;
  late String _selectedSize;
  late String _selectedType;
p

  @override
  void initState() {
    super.initState();
    // Initialize dropdown values with the first item from each list
    _selectedIndustry = _industries[0];
    _selectedSize = _companySizes[0];
    _selectedType = _companyTypes[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _logoController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final companyProfile = CompanyProfileModel(
        name: _nameController.text,
        // categoryType is default 'company' in the model
        website: _websiteController.text,
        logo: _logoController.text,
        description: _descriptionController.text,
        industry: _selectedIndustry,
        location: LocationModel(
          country: _countryController.text,
          city: _cityController.text,
        ),
        size: _selectedSize,
        type: _selectedType,
      );

      ref.read(companyProfileViewModelProvider.notifier).createCompanyProfile(companyProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProfileViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Showing success message and navigating back
    if (state.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset state and navigate back
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(companyProfileViewModelProvider.notifier).resetState();
          context.pop();
        });
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        leadingAction: () => context.pop(),
        searchBar: Container(), // Empty container as per your existing pattern
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
                                ? AppColors.darkSecondaryText
                                : AppColors.lightTextColor,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        
                        // Company name
                        CompanyFormField(
                          label: 'Company Name *',
                          hintText: 'Enter company name',
                          controller: _nameController,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter company name';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Category Type field removed as requested

                        // Website
                        CompanyFormField(
                          label: 'Website',
                          hintText: 'https://www.example.com',
                          controller: _websiteController,
                          keyboardType: TextInputType.url,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 16.h),

                        // Logo picker
                        CompanyLogoPicker(
                          isDarkMode: isDarkMode,
                          onLogoSelected: (String logoUrl) {
                            setState(() {
                              _logoController.text = logoUrl;
                            });

                          },
                        ),
                        SizedBox(height: 16.h),

                        // Description
                        CompanyFormField(
                          label: 'Company Description *',
                          hintText: 'Describe your company',
                          controller: _descriptionController,

                          isMultiline: true,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter company description';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Industry dropdown
                        CompanyDropdownField(
                          label: 'Industry *',
                          value: _selectedIndustry,
                          items: _industries,
                          onChanged: (value) {
                            if (value != null && _industries.contains(value)) {
                              setState(() {
                                _selectedIndustry = value;
                              });

                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 16.h),

                        // Location
                        Text(
                          'Location',
                          style: TextStyles.font20_700Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkSecondaryText
                                : AppColors.lightTextColor,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Country
                        CompanyFormField(
                          label: 'Country *',
                          hintText: 'Enter country',
                          controller: _countryController,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter country';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // City
                        CompanyFormField(
                          label: 'City *',
                          hintText: 'Enter city',
                          controller: _cityController,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter city';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Company size dropdown
                        CompanyDropdownField(
                          label: 'Company Size',
                          value: _selectedSize,
                          items: _companySizes,
                          onChanged: (value) {
                            if (value != null && _companySizes.contains(value)) {
                              setState(() {
                                _selectedSize = value;
                              });

                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 16.h),

                        // Company type dropdown
                        CompanyDropdownField(
                          label: 'Company Type',
                          value: _selectedType,
                          items: _companyTypes,
                          onChanged: (value) {
                            if (value != null && _companyTypes.contains(value)) {
                              setState(() {
                                _selectedType = value;
                              });

                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 32.h),

                        // Submit button
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
                        
                        // Error message
                        if (state.isError) ...[
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
                              state.errorMessage ?? 'An error occurred while creating the company profile',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.sp,
                              ),
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