import 'package:flutter/foundation.dart' show immutable;
import 'package:link_up/features/profile/model/skills_model.dart'; 
import 'package:flutter/foundation.dart' show immutable, listEquals, setEquals;
@immutable
sealed class AddSkillState {
  const AddSkillState();
}

class AddSkillInitial extends AddSkillState {
  const AddSkillInitial();
}

class AddSkillLoadingItems extends AddSkillState {
  const AddSkillLoadingItems();
}

class AddSkillDataLoaded extends AddSkillState {
  final String currentSkillName;
  final List<LinkableItem> availableExperiences;
  final List<LinkableItem> availableEducations;
  final List<LinkableItem> availableLicenses;
  final Set<String> selectedExperienceIds;
  final Set<String> selectedEducationIds;
  final Set<String> selectedLicenseIds;

  const AddSkillDataLoaded({
    this.currentSkillName = '',
    required this.availableExperiences,
    required this.availableEducations,
    required this.availableLicenses,
    this.selectedExperienceIds = const {},
    this.selectedEducationIds = const {},
    this.selectedLicenseIds = const {},
  });

  bool get canSave => currentSkillName.trim().isNotEmpty;

  AddSkillDataLoaded copyWith({
    String? currentSkillName,
    List<LinkableItem>? availableExperiences,
    List<LinkableItem>? availableEducations,
    List<LinkableItem>? availableLicenses,
    Set<String>? selectedExperienceIds,
    Set<String>? selectedEducationIds,
    Set<String>? selectedLicenseIds,
  }) {
    return AddSkillDataLoaded(
      currentSkillName: currentSkillName ?? this.currentSkillName,
      availableExperiences: availableExperiences ?? this.availableExperiences,
      availableEducations: availableEducations ?? this.availableEducations,
      availableLicenses: availableLicenses ?? this.availableLicenses,
      selectedExperienceIds: selectedExperienceIds ?? this.selectedExperienceIds,
      selectedEducationIds: selectedEducationIds ?? this.selectedEducationIds,
      selectedLicenseIds: selectedLicenseIds ?? this.selectedLicenseIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddSkillDataLoaded &&
          runtimeType == other.runtimeType &&
          currentSkillName == other.currentSkillName &&
          listEquals(availableExperiences, other.availableExperiences) &&
          listEquals(availableEducations, other.availableEducations) &&
          listEquals(availableLicenses, other.availableLicenses) &&
          setEquals(selectedExperienceIds, other.selectedExperienceIds) &&
          setEquals(selectedEducationIds, other.selectedEducationIds) &&
          setEquals(selectedLicenseIds, other.selectedLicenseIds);

  @override
  int get hashCode =>
      currentSkillName.hashCode ^
      availableExperiences.hashCode ^
      availableEducations.hashCode ^
      availableLicenses.hashCode ^
      selectedExperienceIds.hashCode ^
      selectedEducationIds.hashCode ^
      selectedLicenseIds.hashCode;
}


class AddSkillSaving extends AddSkillState {
  final AddSkillDataLoaded previousData; 
  const AddSkillSaving({required this.previousData});
}

class AddSkillSuccess extends AddSkillState {
  const AddSkillSuccess();
}

class AddSkillError extends AddSkillState {
  final String message;
  final AddSkillDataLoaded? previousData; 

  const AddSkillError(this.message, {this.previousData});

   @override
   bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddSkillError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          previousData == other.previousData;

   @override
   int get hashCode => message.hashCode ^ previousData.hashCode;
}