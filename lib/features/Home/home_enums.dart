import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';

enum Visibilities { anyone, connectionsOnly, noOne }

enum Reaction {
  like,
  celebrate,
  support,
  love,
  insightful,
  funny,
  none;

  static Reaction getReaction(String reaction) {
    switch (reaction) {
      case 'like':
        return Reaction.like;
      case 'celebrate':
        return Reaction.celebrate;
      case 'support':
        return Reaction.support;
      case 'love':
        return Reaction.love;
      case 'insightful':
        return Reaction.insightful;
      case 'funny':
        return Reaction.funny;
      default:
        return Reaction.none;
    }
  }

  static Icon getIcon(Reaction reaction) {
    switch (reaction) {
      case Reaction.like:
        return const Icon(
          Icons.thumb_up_alt,
          color: AppColors.darkBlue,
        );
      case Reaction.celebrate:
        return const Icon(
          Icons.celebration,
          color: Colors.green,
        );
      case Reaction.support:
        return Icon(
          Icons.support,
          color: Colors.purple[300],
        );
      case Reaction.love:
        return const Icon(
          Icons.favorite,
          color: AppColors.red,
        );
      case Reaction.insightful:
        return const Icon(
          Icons.lightbulb,
          color: AppColors.amber,
        );
      case Reaction.funny:
        return const Icon(
          Icons.emoji_emotions,
          color: AppColors.lightBlue,
        );
      case Reaction.none:
        return const Icon(
          Icons.thumb_up_alt_outlined,
        );
    }
  }
}
