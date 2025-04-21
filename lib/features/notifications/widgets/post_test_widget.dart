import 'package:flutter/material.dart';

class PostPagetest extends StatelessWidget {
  final String postId;

  const PostPagetest({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Page - $postId'),
      ),
      body: Center(
        child: Text(
          'This is a placeholder for the post with ID: $postId',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
