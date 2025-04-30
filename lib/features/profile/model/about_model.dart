// lib/features/profile/model/about_model.dart
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AboutModel {
  final String about;
  final List<String> skills; // Assuming skills are just strings for now

  const AboutModel({
    required this.about,
    required this.skills,
  });

  // Factory constructor to create an instance from JSON
  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      about: json['about'] as String? ?? '', // Handle potential null 'about'
      // Safely parse skills list, ensuring elements are strings
      skills: (json['skills'] as List?)
              ?.map((item) => item.toString()) // Convert each item to string
              .toList() ?? // Convert iterable to list
          [], // Default to empty list if 'skills' is null or not a list
    );
  }

  // No toJson needed currently, as we only PUT the 'about' text
}
