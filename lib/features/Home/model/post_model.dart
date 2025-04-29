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
  List<String> taggedUsers = [];
  List<dynamic> topReactions = [];

  bool saved;

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
    this.taggedUsers = const [],
    this.saved = false,
  });

  PostModel.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        header = HeaderModel.fromJson(json),
        text = json['content'],
        media = Media.fromJson(json['media']),
        reactions =  json['reactionsCount'] ?? json['reacts'].length ?? 0,
        comments =  json['commentsCount'] ??json['comments'].length ?? 0,
        reposts = json['reposts'] ?? json['repostsCount'] ?? 0,
        reaction = Reaction.getReaction(json['userReaction'] ?? 'none'),
        isAd = json['isAd'] ?? false,
        isCompany = json['isCompany'] ?? false,
        saved = json['saved'] ?? false,
        topReactions = List<Reaction>.from(
            json['topReactions']?.map((e) => Reaction.getReaction(e)) ?? []),
        taggedUsers = List<String>.from(json['tagged_users'] ?? []);

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
        'taggedUsers': taggedUsers,
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
    List<String>? taggedUsers,
    bool? saved,
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
      saved: saved ?? this.saved,
      taggedUsers: taggedUsers ?? this.taggedUsers,
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
        saved = false,
        taggedUsers = [],
        isCompany = false;
}
