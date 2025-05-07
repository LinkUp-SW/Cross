import 'package:flutter/material.dart';

class ProfilePagetest extends StatelessWidget {
  final String userId;

  const ProfilePagetest({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page - $userId'),
      ),
      body: Center(
        child: Text(
          'This is a placeholder for the profile with ID: $userId',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
