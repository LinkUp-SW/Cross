
import 'package:link_up/features/Home/model/header_model.dart';

class CommentModel {
  HeaderModel header;
  String text;
  int likes;
  int replies;

  CommentModel({
    required this.header,
    required this.text,
    required this.likes,
    required this.replies,
  });

}