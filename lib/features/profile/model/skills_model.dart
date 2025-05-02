import 'package:flutter/foundation.dart' show immutable;

@immutable
class SkillModel {
  final String? id;
  final String name;
  final List<String>? educations;
  final List<String>? experiences; 
  final List<String>? licenses;    

  const SkillModel({
    this.id,
    required this.name,
    this.educations,
    this.experiences,
    this.licenses,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    List<String>? extractIds(dynamic listData) {
      if (listData is List) {
        return listData.map((item) {
          if (item is String) {
            return item; 
          } else if (item is Map<String, dynamic> && item.containsKey('_id')) {
            return item['_id']?.toString(); 
          }
          return null; 
        }).whereType<String>().toList(); 
      }
      return null; 
    }

    return SkillModel(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      educations: extractIds(json['educations']),
      experiences: extractIds(json['experiences']),
      licenses: extractIds(json['licenses']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name.trim(),
    };
    if (educations != null && educations!.isNotEmpty) {
      data['educations'] = educations;
    }
    if (experiences != null && experiences!.isNotEmpty) {
      data['experiences'] = experiences;
    }
    if (licenses != null && licenses!.isNotEmpty) {
      data['licenses'] = licenses;
    }
    return data;
  }
}

@immutable
class LinkableItem {
  final String id;
  final String title;
  final String subtitle;
  final String type;

  const LinkableItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}