import 'package:flutter/foundation.dart' show immutable;

@immutable
class AddSectionState {
  final bool isLoading;
  final bool hasAboutInfo;
  final bool hasResume;
  final bool hasLicenses;
  final String? error;

  const AddSectionState({
    this.isLoading = true,
    this.hasAboutInfo = false,
    this.hasResume = false,
    this.hasLicenses = false,
    this.error,
  });

  AddSectionState copyWith({
    bool? isLoading,
    bool? hasAboutInfo,
    bool? hasResume,
    bool? hasLicenses,
    String? error,
    bool clearError = false,
  }) {
    return AddSectionState(
      isLoading: isLoading ?? this.isLoading,
      hasAboutInfo: hasAboutInfo ?? this.hasAboutInfo,
      hasResume: hasResume ?? this.hasResume,
      hasLicenses: hasLicenses ?? this.hasLicenses,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddSectionState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          hasAboutInfo == other.hasAboutInfo &&
          hasResume == other.hasResume &&
          hasLicenses == other.hasLicenses &&
          error == other.error;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      hasAboutInfo.hashCode ^
      hasResume.hashCode ^
      hasLicenses.hashCode ^
      error.hashCode;
}