
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';

class CommentModel {
  String id;
  HeaderModel header;
  String text;
  int likes;
  int replies;
  Media media;

  CommentModel({
    required this.id,
    required this.header,
    required this.text,
    required this.likes,
    required this.replies,
    required this.media,
  });


  CommentModel.fromJson(Map<String, dynamic> json)
      : header = HeaderModel.fromJson(json['header']),
        id = json['id'],
        text = json['text'],
        likes = json['likes'],
        replies = json['replies'],
        media = Media.fromJson(json['media']);


  Map<String, dynamic> toJson() => {
        'id': id,
        'header': header.toJson(),
        'text': text,
        'likes': likes,
        'replies': replies,
        'media': media.toJson(),
      };

  CommentModel copyWith({
    String? id,
    HeaderModel? header,
    String? text,
    int? likes,
    int? replies,
    Media? media,
  }) {
    return CommentModel(
      id: id ?? this.id,
      header: header ?? this.header,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      media: media ?? this.media,
    );
  }


  CommentModel.initial()
      : header = HeaderModel.initial(),
        id = '1',
        text = 'This is a test comment',
        likes = 0,
        replies = 0,
        media = Media.initial();

}