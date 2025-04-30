import 'package:flutter/foundation.dart' show immutable;

@immutable
class AddSectionState {
  final bool isLoading;
  final bool hasAboutInfo; 
  final String? error;

  const AddSectionState({
    this.isLoading = true,
    this.hasAboutInfo = false,
    this.error,
  });

  AddSectionState copyWith({
    bool? isLoading,
    bool? hasAboutInfo,
    String? error,
    bool clearError = false, 
  }) {
    return AddSectionState(
      isLoading: isLoading ?? this.isLoading,
      hasAboutInfo: hasAboutInfo ?? this.hasAboutInfo,
      error: clearError ? null : error ?? this.error,
    );
  }
}
