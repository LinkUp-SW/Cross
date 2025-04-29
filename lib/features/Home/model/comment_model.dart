import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';

class CommentModel {
  String id;
  String postId;
  HeaderModel header;
  String text;
  int likes;
  Reaction reaction = Reaction.none;
  int replies;
  Media media;
  bool isReply = false;
  List<dynamic> taggedUsers;
  List<CommentModel> repliesList = [];

  CommentModel({
    required this.postId,
    required this.id,
    required this.header,
    required this.text,
    required this.likes,
    required this.reaction,
    required this.replies,
    required this.media,
    this.isReply = false,
    this.taggedUsers = const [],
  });

  CommentModel.fromJson(Map<String, dynamic> json)
      : header = HeaderModel.fromJson(json),
        id = json['_id'],
        postId = json['post_id'],
        text = json['content'],
        likes = json['reactionsCount'] ?? 0,
        replies = json['childrenCount'] ?? 0,
        taggedUsers = List<String>.from(json['tagged_users'] ?? []),
        reaction = Reaction.getReaction(json['userReaction'] ?? 'none'),
        repliesList =json['children'] != null  ? (json['children'] as List).map((e) => CommentModel.fromJson(e)).toList(): [],
        media = json['media'] != null ?  Media.fromJson(json['media']): Media.initial();

  Map<String, dynamic> toJson() => {
        'id': id,
        'header': header.toJson(),
        'text': text,
        'likes': likes,
        'replies': replies,
        'media': media.toJson(),
        'tagged_users': taggedUsers,
      };

  CommentModel copyWith({
    String? id,
    HeaderModel? header,
    String? text,
    int? likes,
    int? replies,
    Media? media,
    Reaction? reaction,
    List<dynamic>? taggedUsers,
    bool? isReply,
    String ? postId,
  }) {
    return CommentModel(
      postId: postId ?? this.postId,
      id: id ?? this.id,
      header: header ?? this.header,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      reaction: reaction ?? this.reaction,
      replies: replies ?? this.replies,
      media: media ?? this.media,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      isReply: isReply ?? this.isReply,
    );
  }

  CommentModel.initial()
      : header = HeaderModel.initial(),
        id = '1',
        postId = '1',
        text = 'This is a test comment',
        likes = 0,
        replies = 0,
        taggedUsers = [],
        isReply = false,
        media = Media.initial();
}
