import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';

enum Visibilities { anyone, connectionsOnly, noOne;
  
    static Visibilities getVisibility(String visibility) {
      switch (visibility) {
        case 'anyone':
          return Visibilities.anyone;
        case 'connectionsOnly':
          return Visibilities.connectionsOnly;
        case 'noOne':
          return Visibilities.noOne;
        default:
          return Visibilities.anyone;
      }
    }
  
    static String getVisibilityString(Visibilities visibility) {
      switch (visibility) {
        case Visibilities.anyone:
          return 'Anyone';
        case Visibilities.connectionsOnly:
          return 'Connections Only';
        case Visibilities.noOne:
          return 'No One';
      }
    }
  }


enum MediaType {
  image,
  images,
  video,
  pdf,
  none;

  static MediaType getMediaType(String mediaType) {
    switch (mediaType) {
      case 'image':
        return MediaType.image;
      case 'images':
        return MediaType.images;
      case 'video':
        return MediaType.video;
      case 'pdf':
        return MediaType.pdf;
      default:
        return MediaType.none;
    }
  }
}

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

  static String getReactionString(Reaction reaction) {
    switch (reaction) {
      case Reaction.like:
        return 'Like';
      case Reaction.celebrate:
        return 'Celebrate';
      case Reaction.support:
        return 'Support';
      case Reaction.love:
        return 'Love';
      case Reaction.insightful:
        return 'Insightful';
      case Reaction.funny:
        return 'Funny';
      case Reaction.none:
        return 'Like';
    }
  }

  static Color? getColor(Reaction reaction) {
    switch (reaction) {
      case Reaction.like:
        return AppColors.darkBlue;
      case Reaction.celebrate:
        return Colors.green;
      case Reaction.support:
        return Colors.purple[300]!;
      case Reaction.love:
        return AppColors.red;
      case Reaction.insightful:
        return AppColors.amber;
      case Reaction.funny:
        return AppColors.lightBlue;
      case Reaction.none:
        return null;
    }
  }
}
