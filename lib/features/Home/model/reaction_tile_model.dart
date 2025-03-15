

import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';

class ReactionTileModel {
  HeaderModel header;
  Reaction reaction;

  ReactionTileModel({
    required this.header,
    required this.reaction,
  });

  ReactionTileModel.fromJson(Map<String, dynamic> json)
      : header = HeaderModel.fromJson(json['header']),
        reaction = Reaction.getReaction(json['reaction']);
}