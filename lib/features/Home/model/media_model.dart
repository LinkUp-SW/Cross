
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
  List<dynamic> file;

  Media({required this.type, required this.urls,this.file = const []});

  Media.fromJson(Map<String, dynamic> json)
      : type = MediaType.getMediaType(json['type']),
        urls = List<String>.from(json['urls']),
        file = [];

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'urls': urls,
      };

  Media copyWith({
    MediaType? type,
    List<String>? urls,
    List<dynamic>? file,
  }) {
    return Media(
      type: type ?? this.type,
      urls: urls ?? this.urls,
      file: file ?? this.file, 
    );
  }

  Media.initial()
      : type = MediaType.none,
        urls = [],
        file = [];
        
  Widget getMedia({PostModel? post}) {
    switch (type) {
      case MediaType.image:
        return Image.network(urls[0]);
      case MediaType.images:
        return CarouselImages(images: urls);
      case MediaType.video:
        return VideoPlayerHome(videoUrl: urls[0]);
      case MediaType.pdf:
        return PDFViewer(url: urls[0]);
      case MediaType.link:
        return AnyLinkPreview(link: urls[0]);
      case MediaType.post:
        return Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: AppColors.blueHue, width: 0),
          ),
          child: Posts(post: post!,showBottom: false,showTop: false,));
      default:
        return const SizedBox();
    }
  }

  Widget getMediaLocal({PostModel? post}){
    switch (type) {
      case MediaType.image:
        return Image.file(File(file[0].path));
      case MediaType.images:
        return CarouselImages(images: file,network: false,);
      case MediaType.video:
        return VideoPlayerHome(network: false,file: file[0],);
      case MediaType.pdf:
        return PDFViewer(url: file[0],network: false,);
      case MediaType.link:
        return AnyLinkPreview(link: urls[0]);
      case MediaType.post:
        return Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: AppColors.blueHue, width: 0),
          ),
          child: Posts(post: post!,showBottom: false,showTop: false,));
      default:
        return const SizedBox();
    }
  }
}