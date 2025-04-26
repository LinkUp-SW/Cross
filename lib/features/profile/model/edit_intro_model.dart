import 'package:flutter/foundation.dart' show immutable;
import 'package:link_up/features/profile/model/education_model.dart';

@immutable
class EditIntroModel {
  final String firstName;
  final String lastName;
  final String headline;
  final String? countryRegion;
  final String? city;
  final String? selectedEducationId;
  final List<EducationModel> availableEducations;
  final bool showEducationInIntro;
  final String? website;

  const EditIntroModel({
    this.firstName = '',
    this.lastName = '',
    this.headline = '',
    this.countryRegion,
    this.city,
    this.selectedEducationId,
    this.availableEducations = const [],
    this.showEducationInIntro = false,
    this.website,
  });

  String? get selectedEducationInstitution {
    if (selectedEducationId == null) return null;
    try {
      return availableEducations
          .firstWhere((edu) => edu.id == selectedEducationId)
          .institution;
    } catch (e) {
      return null;
    }
  }

  EditIntroModel copyWith({
    String? firstName,
    String? lastName,
    String? headline,
    Object? countryRegion = const Object(),
    Object? city = const Object(),
    Object? selectedEducationId = const Object(),
    List<EducationModel>? availableEducations,
    bool? showEducationInIntro,
    Object? website = const Object(),
  }) {
    return EditIntroModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      headline: headline ?? this.headline,
      countryRegion: countryRegion == const Object()
          ? this.countryRegion
          : countryRegion as String?,
      city: city == const Object() ? this.city : city as String?,
      selectedEducationId: selectedEducationId == const Object()
          ? this.selectedEducationId
          : selectedEducationId as String?,
      availableEducations: availableEducations ?? this.availableEducations,
      showEducationInIntro: showEducationInIntro ?? this.showEducationInIntro,
      website: website == const Object() ? this.website : website as String?,
    );
  }

  @override
  String toString() {
    return 'EditIntroModel(firstName: $firstName, lastName: $lastName, headline: $headline, countryRegion: $countryRegion, city: $city, selectedEducationId: $selectedEducationId, availableEducations: ${availableEducations.length}, showEducationInIntro: $showEducationInIntro, website: $website)';
  }
}