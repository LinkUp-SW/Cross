// lib/features/company_profile/model/company_profile_model.dart

class CompanyProfileModel {
  final String? name;
  String categoryType;
  final String? website;
  final String? logo;
  final String? description;
  final String? industry;
  final LocationModel? location;
  final String? size;
  final String? type;

  CompanyProfileModel({
    this.name,
    this.categoryType = 'company',
    this.website,
    this.logo,
    this.description,
    this.industry,
    this.location,
    this.size,
    this.type,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      name: json['name'] ?? '',
      categoryType: json['category_type'] ?? 'company',
      website: json['website'] ?? '',
      logo: json['logo'] ?? '',
      description: json['description'] ?? '',
      industry: json['industry'] ?? '',
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
      size: json['size'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_type': categoryType,
      'website': website,
      'logo': logo,
      'description': description,
      'industry': industry,
      'location': location?.toJson(),
      'size': size,
      'type': type,
    };
  }
}

class LocationModel {
  final String? country;
  final String? city;

  LocationModel({
    this.country,
    this.city,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      country: json['country'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (country != null && country!.isNotEmpty) data['country'] = country;
    if (city != null && city!.isNotEmpty) data['city'] = city;
    return data;
  }
  }
