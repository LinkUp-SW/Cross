import 'package:flutter/material.dart';
import '../widgets/video_player.dart'; // Import the shared widget

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: VideoPlayerWidget(mediaPath: videoPath, isNetwork: videoPath.startsWith('http')),
      ),
    );
  }
}
