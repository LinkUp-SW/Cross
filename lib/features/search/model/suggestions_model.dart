import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class SuggestionsModel {
  final String name;
  final String? connectionDegree;
  final String? desc;
  final String? imageUrl;
  final String type;

  SuggestionsModel(
      {required this.type,
      required this.name,
      this.imageUrl,
      this.connectionDegree,
      this.desc});

  factory SuggestionsModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'user') {
      return SuggestionsModel(
        type: json['type'] as String,
        name: json['name'] as String,
        imageUrl: json['profile_photo'] as String,
        connectionDegree: json['connection_degree'] as String,
        desc: json['headline'] as String,
      );
    } else if (json['type'] == 'organization') {
      return SuggestionsModel(
        type: json['type'] as String,
        name: json['name'] as String,
        imageUrl: json['logo'] as String,
      );
    } else if (json['type'] == 'job') {
      return SuggestionsModel(
        type: json['type'] as String,
        name: json['title'] as String,
        desc: json['industry'].map((e) => e).join(', '),
      );
    } else {
      return SuggestionsModel(
        type: json['type'] as String,
        name: json['name'] as String,
      );
    }
  }

  Widget buildSuggestion() {
    return ListTile(
      dense: true,
      leading: Icon(Icons.search),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.r),
            ),
            if (connectionDegree != null)
              TextSpan(
                text: ' • ($connectionDegree)',
                style: TextStyle(color: AppColors.grey, fontSize: 10.r),
              ),
            if (desc != null)
              WidgetSpan(
                  child: Text(
                ' • $desc',
                style: TextStyle(color: AppColors.grey, fontSize: 10.r),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          ],
        ),
      ),
      trailing: imageUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(imageUrl!),
            )
          : Icon(Icons.arrow_forward),
    );
  }
}