import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';

class CommentModel {
  String id;
  HeaderModel header;
  String text;
  int likes;
  int replies;
  Media media;
  bool isReply = false;
  List<dynamic> taggedUsers;
  List<CommentModel> repliesList = [];

  CommentModel({
    required this.id,
    required this.header,
    required this.text,
    required this.likes,
    required this.replies,
    required this.media,
    this.isReply = false,
    this.taggedUsers = const [],
  });

  CommentModel.fromJson(Map<String, dynamic> json)
      : header = HeaderModel.fromJson(json),
        id = json['_id'],
        text = json['content'],
        likes = json['reacts'].length,
        replies = json['children'] == null
            ? 0
            : (json['children'] as Map<String, dynamic>).length,
        taggedUsers = List<String>.from(json['tagged_users'] ?? []),
        repliesList = json['children'] == null
            ? []
            : (json['children'] as Map<String, dynamic>)
                .values
                .map((e) => CommentModel.fromJson(e))
                .toList()
                .toList(),
        media = Media.fromJson(json['media']);

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
    List<dynamic>? taggedUsers,
    bool? isReply,
  }) {
    return CommentModel(
      id: id ?? this.id,
      header: header ?? this.header,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      media: media ?? this.media,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      isReply: isReply ?? this.isReply,
    );
  }

  CommentModel.initial()
      : header = HeaderModel.initial(),
        id = '1',
        text = 'This is a test comment',
        likes = 0,
        replies = 0,
        taggedUsers = [],
        isReply = false,
        media = Media.initial();
}
