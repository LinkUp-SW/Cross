import 'package:flutter/material.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/widgets/carousel_images.dart';
import 'package:link_up/features/Home/widgets/pdf_viewer.dart';
import 'package:link_up/features/Home/widgets/video_player_home.dart';

class PostModel {
  String id;

  HeaderModel header;
  String text;
  Media media;

  int reactions;
  int comments;
  int reposts;

  Reaction reaction;

  PostModel({
    required this.id,
    required this.header,
    required this.text,
    required this.media,
    required this.reactions,
    required this.comments,
    required this.reposts,
    required this.reaction,
  });

  PostModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        header = HeaderModel.fromJson(json['header']),
        text = json['text'],
        media = Media.fromJson(json['media']),
        reactions = json['reactions'],
        comments = json['comments'],
        reposts = json['reposts'],
        reaction = Reaction.getReaction(json['reaction']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'header': header.toJson(),
        'text': text,
        'media': media.toJson(),
        'reactions': reactions,
        'comments': comments,
        'reposts': reposts,
        'reaction': reaction.toString(),
      };

  
}

class Media {
  MediaType type;
  List<String> urls;

  Media({required this.type, required this.urls});

  Media.fromJson(Map<String, dynamic> json)
      : type = MediaType.getMediaType(json['type']),
        urls = List<String>.from(json['urls']);

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'urls': urls,
      };

  //TODO: Should be moved to viewModel
  Widget getMedia() {
    switch (type) {
      case MediaType.image:
        return Image.network(urls[0]);
      case MediaType.images:
        return CarouselImages(images: urls);
      case MediaType.video:
        return VideoPlayerHome(videoUrl: urls[0]);
      case MediaType.pdf:
        return PDFViewer(url: urls[0]);
      default:
        return const SizedBox();
    }
  }
}
