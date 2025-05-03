import 'package:flutter/material.dart';
import 'package:link_up/features/profile/model/license_model.dart'; 

@immutable
sealed class AddLicenseState {
  const AddLicenseState();
}

class AddLicenseFormData extends AddLicenseState {
  final TextEditingController nameController;
  final TextEditingController organizationController; 
  final TextEditingController issueDateController;
  final TextEditingController expirationDateController;
  final TextEditingController credentialIdController;
  final TextEditingController credentialUrlController;

  final Map<String, dynamic>? selectedOrganization; 
  final DateTime? selectedIssueDate;
  final DateTime? selectedExpirationDate;
  final bool doesNotExpire;
  final List<String>? skills; 

  const AddLicenseFormData({
    required this.nameController,
    required this.organizationController,
    required this.issueDateController,
    required this.expirationDateController,
    required this.credentialIdController,
    required this.credentialUrlController,
    this.selectedOrganization,
    this.selectedIssueDate,
    this.selectedExpirationDate,
    this.doesNotExpire = false,
    this.skills,
  });

  factory AddLicenseFormData.initial() {
    return AddLicenseFormData(
      nameController: TextEditingController(),
      organizationController: TextEditingController(),
      issueDateController: TextEditingController(),
      expirationDateController: TextEditingController(),
      credentialIdController: TextEditingController(),
      credentialUrlController: TextEditingController(),
    );
  }

  AddLicenseFormData copyWith({
    TextEditingController? nameController,
    TextEditingController? organizationController,
    TextEditingController? issueDateController,
    TextEditingController? expirationDateController,
    TextEditingController? credentialIdController,
    TextEditingController? credentialUrlController,
    Object? selectedOrganization = const Object(),
    Object? selectedIssueDate = const Object(),
    Object? selectedExpirationDate = const Object(),
    bool? doesNotExpire,
    List<String>? skills,
  }) {
    return AddLicenseFormData(
      nameController: nameController ?? this.nameController,
      organizationController: organizationController ?? this.organizationController,
      issueDateController: issueDateController ?? this.issueDateController,
      expirationDateController: expirationDateController ?? this.expirationDateController,
      credentialIdController: credentialIdController ?? this.credentialIdController,
      credentialUrlController: credentialUrlController ?? this.credentialUrlController,
      selectedOrganization: selectedOrganization == const Object()
          ? this.selectedOrganization
          : selectedOrganization as Map<String, dynamic>?,
      selectedIssueDate: selectedIssueDate == const Object()
          ? this.selectedIssueDate
          : selectedIssueDate as DateTime?,
      selectedExpirationDate: selectedExpirationDate == const Object()
          ? this.selectedExpirationDate
          : selectedExpirationDate as DateTime?,
      doesNotExpire: doesNotExpire ?? this.doesNotExpire,
      skills: skills ?? this.skills,
    );
  }
}



class AddLicenseInitial extends AddLicenseState {
  final AddLicenseFormData formData;
  const AddLicenseInitial(this.formData);
}

class AddLicenseLoading extends AddLicenseState {
  final AddLicenseFormData formData;
  const AddLicenseLoading(this.formData);
}

class AddLicenseSuccess extends AddLicenseState {
  const AddLicenseSuccess();
}

class AddLicenseFailure extends AddLicenseState {
  final AddLicenseFormData formData;
  final String message;
  const AddLicenseFailure(this.formData, this.message);
}