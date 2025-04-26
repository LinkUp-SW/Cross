

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
      : header = HeaderModel.fromJson(json),
        reaction = Reaction.getReaction(json['reaction']);

  Map<String, dynamic> toJson() => {
        'header': header.toJson(),
        'reaction': reaction.toString(),
      };

  ReactionTileModel copyWith({
    HeaderModel? header,
    Reaction? reaction,
  }) {
    return ReactionTileModel(
      header: header ?? this.header,
      reaction: reaction ?? this.reaction,
    );
  }

  ReactionTileModel.initial()
      : header = HeaderModel.initial(),
        reaction = Reaction.none;
  
}