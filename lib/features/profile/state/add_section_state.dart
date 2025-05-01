import 'package:flutter/foundation.dart' show immutable;

@immutable
class AddSectionState {
  final bool isLoading;
  final bool hasAboutInfo;
  final bool hasResume; // <-- Add hasResume flag
  final String? error;

  const AddSectionState({
    this.isLoading = true,
    this.hasAboutInfo = false,
    this.hasResume = false, // <-- Initialize
    this.error,
  });

  AddSectionState copyWith({
    bool? isLoading,
    bool? hasAboutInfo,
    bool? hasResume, // <-- Add to copyWith
    String? error,
    bool clearError = false,
  }) {
    return AddSectionState(
      isLoading: isLoading ?? this.isLoading,
      hasAboutInfo: hasAboutInfo ?? this.hasAboutInfo,
      hasResume: hasResume ?? this.hasResume, // <-- Assign in copyWith
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
          hasResume == other.hasResume && // <-- Compare in equality
          error == other.error;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      hasAboutInfo.hashCode ^
      hasResume.hashCode ^ // <-- Include in hashcode
      error.hashCode;
}