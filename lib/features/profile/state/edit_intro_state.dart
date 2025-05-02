import 'package:flutter/foundation.dart' show immutable, mapEquals;
import 'package:link_up/features/profile/model/edit_intro_model.dart';

@immutable
sealed class EditIntroState {
  const EditIntroState();
}

class EditIntroInitial extends EditIntroState {
  const EditIntroInitial();
}

class EditIntroLoading extends EditIntroState {
  const EditIntroLoading();
}

class EditIntroDataState extends EditIntroState {
  final EditIntroModel formData;
  final Map<String, dynamic> originalBioData;

  const EditIntroDataState({required this.formData, required this.originalBioData});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditIntroDataState &&
           other.formData == formData &&
           mapEquals(other.originalBioData, originalBioData);
  }

  @override
  int get hashCode => formData.hashCode ^ originalBioData.hashCode;
}

class EditIntroSaving extends EditIntroState {
  final EditIntroModel formData;
  final Map<String, dynamic> originalBioData;
  const EditIntroSaving({required this.formData, required this.originalBioData});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditIntroSaving &&
           other.formData == formData &&
           mapEquals(other.originalBioData, originalBioData);
  }

  @override
  int get hashCode => formData.hashCode ^ originalBioData.hashCode;
}

class EditIntroSuccess extends EditIntroState {
  const EditIntroSuccess();
}

class EditIntroError extends EditIntroState {
  final String message;
  final EditIntroModel? previousFormData;
  final Map<String, dynamic>? originalBioData;

  const EditIntroError(this.message, {this.previousFormData, this.originalBioData});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditIntroError &&
           other.message == message &&
           other.previousFormData == previousFormData &&
           mapEquals(other.originalBioData, originalBioData);
  }

  @override
  int get hashCode => message.hashCode ^ previousFormData.hashCode ^ originalBioData.hashCode;
}