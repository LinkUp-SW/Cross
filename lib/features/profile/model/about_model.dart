import 'package:flutter/foundation.dart' show immutable;
import 'dart:developer'; 

@immutable
class AboutModel {
  final String about;
  final List<String> skills;

  const AboutModel({
    required this.about,
    required this.skills,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    String parsedAbout = '';
    List<String> parsedSkills = [];

    if (json.containsKey('about') && json['about'] is Map<String, dynamic>) {
      final aboutData = json['about'] as Map<String, dynamic>;
      parsedAbout = aboutData['about'] as String? ?? '';
      parsedSkills = (aboutData['skills'] as List?)
              ?.map((item) => item.toString())
              .whereType<String>() 
              .toList() ??
          [];
      log("AboutModel.fromJson: Parsed nested structure. About: '$parsedAbout', Skills: $parsedSkills");
    } else {
        log("AboutModel.fromJson: Top-level 'about' key is not a Map or is missing. JSON received: $json");

    }


    return AboutModel(
      about: parsedAbout,
      skills: parsedSkills,
    );
  }

}