import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';

class PostModel {
  String id;

  HeaderModel header;
  String text;
  Media media;
  bool isAd = false;
  bool isCompany = false;

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
    this.isAd = false,
    this.isCompany = false,
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
        isCompany = json['isCompany'] ?? false;

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
        'isCompany': isCompany,
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
    bool? isCompany,
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
      isCompany: isCompany ?? this.isCompany,
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
        isCompany = false;
}
