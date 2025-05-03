import 'package:flutter/foundation.dart' show immutable;
import 'dart:developer';

@immutable
class BlockedUser {
  final String userId;
  final String name;
  final String headline;
  final String profilePicture;
  final DateTime date; 

  const BlockedUser({
    required this.userId,
    required this.name,
    required this.headline,
    required this.profilePicture,
    required this.date,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] as String? ?? '');
    } catch (e) {
      log("Error parsing date for blocked user ${json['user_id']}: $e");
      parsedDate = DateTime.now();
    }

    return BlockedUser(
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown User',
      headline: json['headline'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
      date: parsedDate,
    );
  }
}