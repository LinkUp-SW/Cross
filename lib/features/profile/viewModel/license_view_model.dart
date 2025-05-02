import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/license_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';

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

  AddLicenseViewModel(this._profileService, this._ref)
      : super(AddLicenseInitial(AddLicenseFormData.initial())) {
    state = AddLicenseInitial(AddLicenseFormData(
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
    ));
  }

  AddLicenseFormData _getCurrentFormData() {
    final currentState = state;
    if (currentState is AddLicenseInitial) return currentState.formData;
    if (currentState is AddLicenseLoading) return currentState.formData;
    if (currentState is AddLicenseFailure) return currentState.formData;
    return AddLicenseFormData.initial();
  }

  void _updateStateWithFormData(AddLicenseFormData updatedData) {
    final currentState = state;
    if (currentState is AddLicenseInitial || currentState is AddLicenseFailure) {
      state = AddLicenseInitial(updatedData);
    } else if (currentState is AddLicenseLoading) {
      state = AddLicenseLoading(updatedData);
    }
  }

  void setOrganization(Map<String, dynamic>? organization) {
    _selectedOrganization = organization;
    _organizationController.text = organization?['name'] ?? '';
    log("AddLicenseViewModel: Organization set - ID: ${organization?['_id']}, Name: ${organization?['name']}");
    _updateStateWithFormData(_getCurrentFormData().copyWith(
          selectedOrganization: organization,
          organizationController: _organizationController
        ));
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
    _updateStateWithFormData(_getCurrentFormData().copyWith(
      selectedIssueDate: _selectedIssueDate,
      selectedExpirationDate: _selectedExpirationDate,
      issueDateController: _issueDateController,
      expirationDateController: _expirationDateController,
    ));
  }

  void setDoesNotExpire(bool value) {
    _doesNotExpire = value;
    if (_doesNotExpire) {
      _selectedExpirationDate = null;
      _expirationDateController.clear();
    } else {
      if (_selectedExpirationDate != null) {
        _expirationDateController.text = DateFormat('yyyy-MM-dd').format(_selectedExpirationDate!);
      } else {
        _expirationDateController.clear();
      }
    }
    _updateStateWithFormData(_getCurrentFormData().copyWith(
      doesNotExpire: _doesNotExpire,
      selectedExpirationDate: _selectedExpirationDate,
      expirationDateController: _expirationDateController,
    ));
  }

  String? validateForm() {
    final formData = _getCurrentFormData();
    if (formData.nameController.text.trim().isEmpty) return "License name is required.";
    if (formData.organizationController.text.trim().isEmpty || _selectedOrganization == null) {
      return "Issuing organization is required.";
    }
    if (formData.issueDateController.text.isEmpty) return "Issue date is required.";

    if (!formData.doesNotExpire && formData.expirationDateController.text.isEmpty) {
      return "Expiration date is required (or check 'This credential does not expire').";
    }

    if (!formData.doesNotExpire && _selectedIssueDate != null && _selectedExpirationDate != null) {
      if (_selectedExpirationDate!.isBefore(_selectedIssueDate!)) {
        return "Expiration date cannot be before the issue date.";
      }
    }

    final url = formData.credentialUrlController.text.trim();
        if (url.isNotEmpty && (Uri.tryParse(url)?.isAbsolute != true)) {
          return "Please enter a valid Credential URL (e.g., https://example.com).";
        }

    return null;
  }

  Future<void> saveLicense() async {
    final currentFormData = _getCurrentFormData();
    final validationError = validateForm();

    if (validationError != null) {
      state = AddLicenseFailure(currentFormData, validationError);
      state = AddLicenseInitial(currentFormData);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Use listener in UI to show snackbar for the failure message
        });
      return;
    }

    state = AddLicenseLoading(currentFormData);

    final licenseModel = LicenseModel(
      name: currentFormData.nameController.text.trim(),
      issuingOrganizationId: currentFormData.selectedOrganization?['_id'] as String?,
      issuingOrganizationName: currentFormData.organizationController.text.trim(),
      issuingOrganizationLogoUrl: currentFormData.selectedOrganization?['logo'] as String?,
      issueDate: _selectedIssueDate,
      expirationDate: _doesNotExpire ? null : _selectedExpirationDate,
      doesNotExpire: _doesNotExpire,
      credentialId: currentFormData.credentialIdController.text.trim().isNotEmpty
          ? currentFormData.credentialIdController.text.trim()
          : null,
      credentialUrl: currentFormData.credentialUrlController.text.trim().isNotEmpty
          ? currentFormData.credentialUrlController.text.trim()
          : null,
      skills: _skills,
    );

    try {
      final success = await _profileService.addLicense(licenseModel);
      if (success && mounted) {
        state = const AddLicenseSuccess();
        await _ref.read(profileViewModelProvider.notifier).fetchUserProfile();
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

    state = AddLicenseInitial(AddLicenseFormData(
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
    ));
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