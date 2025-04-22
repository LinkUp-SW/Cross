

import 'package:flutter/foundation.dart' show immutable;
import 'package:intl/intl.dart'; 

@immutable
class ContactInfoModel {
  final String? phoneNumber;
  final String? countryCode; 
  final String? phoneType; 
  final String? address;
  final DateTime? birthday;
  final String? website;

  const ContactInfoModel({
    this.phoneNumber,
    this.countryCode, 
    this.phoneType,
    this.address,
    this.birthday,
    this.website,
  });

  factory ContactInfoModel.initial() {
    return const ContactInfoModel(
      phoneNumber: null,
      countryCode: null, 
      phoneType: null,
      address: null,
      birthday: null,
      website: null,
    );
  }

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      phoneNumber: json['phone_number']?.toString(),
      countryCode: json['country_code'] as String?, // Added
      phoneType: json['phone_type'] as String?,
      address: json['address'] as String?,
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phoneNumber != null) 'phone_number': phoneNumber, 
      if (countryCode != null) 'country_code': countryCode,
      if (phoneType != null) 'phone_type': phoneType,
      if (address != null) 'address': address,
      if (birthday != null) 'birthday': birthday!.toIso8601String(),
      if (website != null) 'website': website,
    };
  }

  ContactInfoModel copyWith({
    String? phoneNumber,
    String? countryCode, // Added
    String? phoneType,
    String? address,
    DateTime? birthday,
    String? website,
  }) {
    return ContactInfoModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode, // Added
      phoneType: phoneType ?? this.phoneType,
      address: address ?? this.address,
      birthday: birthday ?? this.birthday,
      website: website ?? this.website,
    );
  }
}