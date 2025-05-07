import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/license_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'dart:async';



class AddLicenseViewModel extends StateNotifier<AddLicenseState> {
  final ProfileService _profileService;
  final Ref _ref;

  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expirationDateController = TextEditingController();
  final _credentialIdController = TextEditingController();
  final _credentialUrlController = TextEditingController();

  Map<String, dynamic>? _selectedOrganization;
  DateTime? _selectedIssueDate;
  DateTime? _selectedExpirationDate;
  bool _doesNotExpire = false;
  List<String>? _skills; 

  String? _editingLicenseId;
  bool get isEditMode => _editingLicenseId != null;

  AddLicenseViewModel(this._profileService, this._ref)
      : super(AddLicenseInitial(AddLicenseFormData.initial())) {
     state = AddLicenseInitial(_createFormData());
  }

  AddLicenseFormData _createFormData() {
    return AddLicenseFormData(
      nameController: _nameController,
      organizationController: _organizationController,
      issueDateController: _issueDateController,
      expirationDateController: _expirationDateController,
      credentialIdController: _credentialIdController,
      credentialUrlController: _credentialUrlController,
      selectedOrganization: _selectedOrganization,
      selectedIssueDate: _selectedIssueDate,
      selectedExpirationDate: _selectedExpirationDate,
      doesNotExpire: _doesNotExpire,
      skills: _skills,
    );
  }

  AddLicenseFormData? _getCurrentFormDataFromState() {
    final currentState = state;
    if (currentState is AddLicenseInitial) return currentState.formData;
    if (currentState is AddLicenseLoading) return currentState.formData;
    if (currentState is AddLicenseFailure) return currentState.formData;
    return null;
  }


  void _updateStateWithFormData(AddLicenseFormData updatedData) {
     if (!mounted) return;
     final currentState = state;
     if (currentState is AddLicenseLoading) {
       state = AddLicenseLoading(updatedData);
     } else if (currentState is AddLicenseFailure) {
       state = AddLicenseFailure(updatedData, currentState.message);
     } else { 
       state = AddLicenseInitial(updatedData);
     }
   }

  void initializeForEdit(LicenseModel license) {
     log("Initializing License ViewModel for Edit: ${license.id}");
     _editingLicenseId = license.id;

     _nameController.text = license.name;
     _selectedOrganization = {
         '_id': license.issuingOrganizationId, 
         'name': license.issuingOrganizationName,
         'logo': license.issuingOrganizationLogoUrl, 
     };
     _selectedOrganization?.removeWhere((key, value) => value == null);
     _organizationController.text = license.issuingOrganizationName;

     _doesNotExpire = license.doesNotExpire;
     _selectedIssueDate = license.issueDate;
     _selectedExpirationDate = license.expirationDate; 

     _issueDateController.text = _selectedIssueDate != null ? DateFormat('yyyy-MM-dd').format(_selectedIssueDate!) : '';
     _expirationDateController.text = !_doesNotExpire && _selectedExpirationDate != null
         ? DateFormat('yyyy-MM-dd').format(_selectedExpirationDate!):

     _credentialIdController.text = license.credentialId ?? '';
     _credentialUrlController.text = license.credentialUrl ?? '';
     _skills = license.skills != null ? List<String>.from(license.skills!) : null;

     _updateStateWithFormData(_createFormData());
     log("License ViewModel Initialized: ID=$_editingLicenseId, Name=${_nameController.text}");
   }


  void setOrganization(Map<String, dynamic>? organization) {
    _selectedOrganization = organization;
    _organizationController.text = organization?['name'] ?? '';
    log("AddLicenseViewModel: Organization set - ID: ${organization?['_id']}, Name: ${organization?['name']}");
    _updateStateWithFormData(_createFormData());
  }

  void setDate(DateTime date, bool isIssueDate) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    if (isIssueDate) {
      _selectedIssueDate = date;
      _issueDateController.text = formattedDate;
    } else {
      if (!_doesNotExpire) {
        _selectedExpirationDate = date;
        _expirationDateController.text = formattedDate;
      }
    }
     _updateStateWithFormData(_createFormData());
  }

  void setDoesNotExpire(bool value) {
    _doesNotExpire = value;
    if (_doesNotExpire) {
      _selectedExpirationDate = null;
      _expirationDateController.clear();
    } else {
      _expirationDateController.text = _selectedExpirationDate != null ? DateFormat('yyyy-MM-dd').format(_selectedExpirationDate!) : '';
    }
     _updateStateWithFormData(_createFormData());
  }

  String? validateForm() {
     final formData = _createFormData(); 
     final today = DateUtils.dateOnly(DateTime.now());
     if (formData.nameController.text.trim().isEmpty) return "License name is required.";
     if (formData.organizationController.text.trim().isEmpty) {
       return "Issuing organization name is required.";
     }
     if (formData.issueDateController.text.isEmpty || _selectedIssueDate == null) return "Issue date is required.";

     if (!formData.doesNotExpire && (formData.expirationDateController.text.isEmpty || _selectedExpirationDate == null)) {
       return "Expiration date is required (or check 'This credential does not expire').";
     }
      if (_selectedIssueDate != null && _selectedIssueDate!.isAfter(today)) {
        return "Issue date cannot be in the future.";
      } 
     if (!formData.doesNotExpire && _selectedIssueDate != null && _selectedExpirationDate != null) {
       if (_selectedExpirationDate!.isBefore(_selectedIssueDate!)) {
         return "Expiration date cannot be before the issue date.";
       }
     }

     final url = formData.credentialUrlController.text.trim();
     if (url.isNotEmpty) {
        try {
          final uri = Uri.parse(url);
          if (!uri.hasAuthority && !uri.hasScheme) {
             if (!url.contains('.')) throw FormatException(); 
          }
        } catch (e) {
           return "Please enter a valid Credential URL (e.g., https://example.com or www.example.com).";
        }
     }

     return null;
   }

  Future<void> saveLicense(List<String> currentSkills) async {
    final currentFormData = _createFormData(); 
    final validationError = validateForm();

    if (validationError != null) {
       _updateStateWithFormData(currentFormData); 
       state = AddLicenseFailure(currentFormData, validationError);

       return;
    }

    state = AddLicenseLoading(currentFormData);

    final licenseModel = LicenseModel(
      id: _editingLicenseId, 
      name: _nameController.text.trim(),
      issuingOrganizationId: _selectedOrganization?['_id'] as String?, 
      issuingOrganizationName: _organizationController.text.trim(), 
      issuingOrganizationLogoUrl: _selectedOrganization?['logo'] as String?,
      issueDate: _selectedIssueDate,
      expirationDate: _doesNotExpire ? null : _selectedExpirationDate,
      doesNotExpire: _doesNotExpire,
      credentialId: _credentialIdController.text.trim().isNotEmpty
          ? _credentialIdController.text.trim()
          : null,
      credentialUrl: _credentialUrlController.text.trim().isNotEmpty
          ? _credentialUrlController.text.trim()
          : null,
      skills: currentSkills.isNotEmpty ? List.from(currentSkills) : null, 
    );

    log("Saving License Data: ${licenseModel.toJson()}"); 

    try {
      bool success;
      if (isEditMode) {
         log("Calling updateLicense for ID: $_editingLicenseId");
         success = await _profileService.updateLicense(_editingLicenseId!, licenseModel);
      } else {
         log("Calling addLicense");
         success = await _profileService.addLicense(licenseModel);
      }

      if (success && mounted) {
        unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile());
        state = const AddLicenseSuccess();
        resetForm();
      } else if (mounted) {
        state = AddLicenseFailure(currentFormData, "Failed to save license. Server error.");
      }
    } catch (e) {
        log("Error saving license: $e");
        if (mounted) {
          state = AddLicenseFailure(currentFormData, "An error occurred: ${e.toString()}");
        }
    }
  }

  void resetForm() {
     log("Resetting License form. Edit mode was: $isEditMode");
     _nameController.clear();
     _organizationController.clear();
     _issueDateController.clear();
     _expirationDateController.clear();
     _credentialIdController.clear();
     _credentialUrlController.clear();

     _selectedOrganization = null;
     _selectedIssueDate = null;
     _selectedExpirationDate = null;
     _doesNotExpire = false;
     _skills = null;
     _editingLicenseId = null;

     if (mounted) {
       state = AddLicenseInitial(_createFormData());
     }
   }


  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _issueDateController.dispose();
    _expirationDateController.dispose();
    _credentialIdController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }
}

final addLicenseViewModelProvider =
    StateNotifierProvider.autoDispose<AddLicenseViewModel, AddLicenseState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return AddLicenseViewModel(profileService, ref);
});