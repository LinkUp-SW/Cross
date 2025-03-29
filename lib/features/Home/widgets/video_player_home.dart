import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHome extends StatefulWidget {
  final String? videoUrl;
  final XFile? file;
  final bool network;

  const VideoPlayerHome(
      {super.key, this.videoUrl, this.file, this.network = true})
      : assert(videoUrl != null || file != null);

  @override
  State<VideoPlayerHome> createState() => _VideoPlayerHomeState();
}

class _VideoPlayerHomeState extends State<VideoPlayerHome> {
  late VideoPlayerController _videoController;

  String getVideoPosition() {
    var duration = Duration(
        milliseconds: (_videoController.value.duration.inMilliseconds -
                _videoController.value.position.inMilliseconds)
            .round());
    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  void initState() {
    super.initState();
    if (widget.network) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              setState(() {});
            });
    } else {
      _videoController = VideoPlayerController.file(File(widget.file!.path))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          log(_videoController.value.aspectRatio.toString());
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController.value.isPlaying) {
            _videoController.pause();
          } else {
            _videoController.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
          if (!_videoController.value.isPlaying)
            CircleAvatar(
              radius: 25.r,
              backgroundColor:
                  AppColors.darkBackground.withValues(alpha: 0.5),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.lightMain,
                size: 30.r,
              ),
            ),
          ValueListenableBuilder(
            valueListenable: _videoController,
            builder: (context, VideoPlayerValue value, child) {
              if (_videoController.value.position ==
                  _videoController.value.duration) {
                return CircleAvatar(
                  radius: 25.r,
                  backgroundColor:
                      AppColors.darkBackground.withValues(alpha: 0.5),
                  child: Icon(
                    Icons.replay,
                    color: AppColors.lightMain,
                    size: 30.r,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          ValueListenableBuilder(
            valueListenable: _videoController,
            builder: (context, VideoPlayerValue value, child) {
              return Positioned(
                top: 5.h,
                right: 5.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Text(
                      getVideoPosition(),
                      style: const TextStyle(color: AppColors.lightMain),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 5.h,
            right: 0,
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (_videoController.value.volume == 0) {
                    _videoController.setVolume(1);
                  } else {
                    _videoController.setVolume(0);
                  }
                });
              },
              icon: CircleAvatar(
                backgroundColor:
                    AppColors.darkBackground.withValues(alpha: 0.5),
                radius: 10.r,
                child: Icon(
                  _videoController.value.volume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: AppColors.lightMain,
                  size: 15.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
