import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/widgets/carousel_images.dart';
import 'package:link_up/features/Home/widgets/pdf_viewer.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/features/Home/widgets/video_player_home.dart';
import 'package:link_up/shared/themes/colors.dart';

class Media {
  MediaType type;
  List<String> urls;
  List<dynamic> files;
  PostModel? post;
  bool isLocal = false;

  Media(
      {required this.type,
      required this.urls,
      this.files = const [],
      this.post,
      this.isLocal = false});

  Media.fromJson(Map<String, dynamic> json,{Map<String, dynamic>? ogPost})
      : type = MediaType.getMediaType(json['media_type']),
        urls = json['link'].runtimeType == String
            ? json['link'] == ''
                ? []
                : [json['link']]
            : List<String>.from(json['link'] ?? []),
        post = ogPost != null ? PostModel.fromJson(ogPost) : null,
        files = [];

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'urls': urls,
      };

  Media copyWith(
      {MediaType? type,
      List<String>? urls,
      List<dynamic>? files,
      PostModel? post}) {
    return Media(
        type: type ?? this.type,
        urls: urls ?? this.urls,
        files: files ?? this.files,
        post: post ?? this.post);
  }

  Media.initial()
      : type = MediaType.none,
        urls = [],
        files = [],
        post = null;

  Widget getMedia() {
    switch (type) {
      case MediaType.image:
        return isLocal
            ? Image.file(File(files[0].path))
            : Image.network(urls[0]);
      case MediaType.images:
        return CarouselImages(
            images: isLocal ? files : urls, network: !isLocal);
      case MediaType.video:
        return VideoPlayerHome(
            videoUrl: !isLocal ? urls[0] : null,
            file: isLocal ? files[0] : null,
            network: !isLocal);
      case MediaType.pdf:
        return PDFViewer(url: isLocal ? files[0] : urls[0], network: !isLocal);
      case MediaType.link:
        return AnyLinkPreview(
          link: urls[0],
          displayDirection: UIDirection.uiDirectionHorizontal,
          backgroundColor: AppColors.fineLinesGrey,
          titleStyle: const TextStyle(color: AppColors.darkSecondaryText),
        );
      case MediaType.post:
        return Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              side: BorderSide(color: AppColors.blueHue, width: 0),
            ),
            child: Posts(
              post: post!,
              showBottom: false,
            ));
      default:
        return const SizedBox();
    }
  }

  Future<List<dynamic>> setToUpload() async {
    final mediaContent = <dynamic>[];

    if (type == MediaType.post) {
      mediaContent.add(post!.id);
    } else if (!isLocal) {
      mediaContent.addAll(urls);
    } else if (type == MediaType.pdf) {
      // For PDF files
      final bytes = await File(files[0]!.path).readAsBytes();
      // Explicitly set mime type for PDF
      final uriData = UriData.fromBytes(bytes, mimeType: 'application/pdf');
      mediaContent.add(uriData.toString());
    } else if (files.isNotEmpty) {
      // For images or other files
      for (int i = 0; i < files.length; i++) {
        if (files[i] != null) {
          final path = files[i]!.path;
          final bytes = await File(path).readAsBytes();

          // Determine MIME type from file extension
          String mimeType = '';
          if (path.toLowerCase().endsWith('.jpg') ||
              path.toLowerCase().endsWith('.jpeg')) {
            mimeType = 'image/jpeg';
          } else if (path.toLowerCase().endsWith('.png')) {
            mimeType = 'image/png';
          } else if (path.toLowerCase().endsWith('.gif')) {
            mimeType = 'image/gif';
          } else if (path.toLowerCase().endsWith('.mp4')) {
            mimeType = 'video/mp4';
          }

          final uriData = UriData.fromBytes(bytes, mimeType: mimeType);
          mediaContent.add(uriData.toString());
        }
      }
    }
    return mediaContent;
  }
}
