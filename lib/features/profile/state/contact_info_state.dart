
import 'package:flutter/foundation.dart' show immutable, mapEquals; 
import 'package:link_up/features/profile/model/contact_info_model.dart';

@immutable
sealed class EditContactInfoState {
  const EditContactInfoState();
}

class EditContactInfoInitial extends EditContactInfoState {
  const EditContactInfoInitial();
}

class EditContactInfoLoading extends EditContactInfoState {
  const EditContactInfoLoading();
}

class EditContactInfoLoaded extends EditContactInfoState {
  final ContactInfoModel contactInfo;
  final Map<String, dynamic> originalBioData;

  const EditContactInfoLoaded({
    required this.contactInfo,
    required this.originalBioData,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditContactInfoLoaded &&
        other.contactInfo == contactInfo &&
        mapEquals(other.originalBioData, originalBioData); 
  }

  @override
  int get hashCode => contactInfo.hashCode ^ originalBioData.hashCode;
}

class EditContactInfoSaving extends EditContactInfoState {
  final ContactInfoModel contactInfo;
  final Map<String, dynamic> originalBioData;

  const EditContactInfoSaving({
    required this.contactInfo,
    required this.originalBioData,
  });

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditContactInfoSaving &&
        other.contactInfo == contactInfo &&
        mapEquals(other.originalBioData, originalBioData); 
  }

  @override
  int get hashCode => contactInfo.hashCode ^ originalBioData.hashCode;
}

class EditContactInfoSuccess extends EditContactInfoState {
  const EditContactInfoSuccess();
}

class EditContactInfoError extends EditContactInfoState {
  final String message;
  final ContactInfoModel? previousContactInfo;
  final Map<String, dynamic>? originalBioData;

  const EditContactInfoError(
   this.message, {
   this.previousContactInfo,
   this.originalBioData,
  });

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditContactInfoError &&
           other.message == message &&
           other.previousContactInfo == previousContactInfo &&
           mapEquals(other.originalBioData, originalBioData); 
  }

   @override
   int get hashCode => message.hashCode ^ previousContactInfo.hashCode ^ originalBioData.hashCode;
}