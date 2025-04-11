import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String mediaPath;
  final bool isNetwork;

  const VideoPlayerWidget({
    Key? key,
    required this.mediaPath,
    this.isNetwork = false,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.isNetwork
        ? VideoPlayerController.network(widget.mediaPath)
        : VideoPlayerController.file(File(widget.mediaPath));

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });

    _initializeController();
  }

  // Initialize the video player controller
  void _initializeController() {
    _controller.initialize().then((_) {
      setState(() {
        _isLoading = false;
      });
      _controller.setLooping(true);
      _controller.setVolume(1.0); // Set volume to 100% initially
    }).catchError((error) {
      print("Error initializing video: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        GestureDetector(
          onTap: _togglePlayPause,
          child: AnimatedOpacity(
            opacity: _isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black38,
              child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
            ),
          ),
        ),
        // Mute/Unmute Button
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: _toggleMute,
          ),
        ),
      ],
    );
  }

  // Toggle between play and pause
  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  // Toggle mute/unmute
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0); // Set volume to 0 if muted
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
