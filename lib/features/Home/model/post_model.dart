import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';

class PostModel {
  String id;

  HeaderModel header;
  String text;
  Media media;
  bool isAd = false;

  int reactions;
  int comments;
  int reposts;
  PostModel? repost;

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
    this.isAd = false,
    this.repost,
  });

  PostModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        header = HeaderModel.fromJson(json['header']),
        text = json['text'],
        media = Media.fromJson(json['media']),
        reactions = json['reactions'],
        comments = json['comments'],
        reposts = json['reposts'],
        reaction = Reaction.getReaction(json['reaction']),
        isAd = json['isAd'] ?? false,
        repost =
            json['repost'] != null ? PostModel.fromJson(json['repost']) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'header': header.toJson(),
        'text': text,
        'media': media.toJson(),
        'reactions': reactions,
        'comments': comments,
        'reposts': reposts,
        'reaction': reaction.toString(),
        'isAd': isAd,
        'repost': repost?.toJson(),
      };

  PostModel copyWith({
    String? id,
    HeaderModel? header,
    String? text,
    Media? media,
    int? reactions,
    int? comments,
    int? reposts,
    Reaction? reaction,
    bool? isAd,
    PostModel? repost,
  }) {
    return PostModel(
      id: id ?? this.id,
      header: header ?? this.header,
      text: text ?? this.text,
      media: media ?? this.media,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      reaction: reaction ?? this.reaction,
      isAd: isAd ?? this.isAd,
      repost: repost ?? this.repost,
    );
  }

  PostModel.initial()
      : id = '5',
        header = HeaderModel.initial(),
        text = 'This is dummy text to try to fill the space',
        media = Media.initial(),
        reactions = 50,
        comments = 5,
        reposts = 5,
        reaction = Reaction.none,
        isAd = false,
        repost = null;
}
