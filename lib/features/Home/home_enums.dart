import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_up/shared/themes/colors.dart';

enum Visibilities { anyone, connectionsOnly, noOne;
  
    static Visibilities getVisibility(String visibility) {
      switch (visibility) {
        case 'anyone' || 'Anyone':
          return Visibilities.anyone;
        case 'connectionsOnly' || 'Connections only':
          return Visibilities.connectionsOnly;
        case 'noOne' || 'No one':
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
          return 'Connections only';
        case Visibilities.noOne:
          return 'No one';
      }
    }
  }


enum MediaType {
  image,
  images,
  video,
  pdf,
  post,
  link,
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
      case 'post':
        return MediaType.post;
      case 'link':
        return MediaType.link;
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
      case 'Like'||'like':
        return Reaction.like;
      case 'Celebrate'||'celebrate':
        return Reaction.celebrate;
      case 'Support'||'support':
        return Reaction.support;
      case 'Love'||'love':
        return Reaction.love;
      case 'Insightful'||'insightful':
        return Reaction.insightful;
      case 'Funny'||'funny':
        return Reaction.funny;
      default:
        return Reaction.none;
    }
  }

  static Widget getIcon(Reaction reaction,double size) {
    switch (reaction) {
      case Reaction.like:
        return SvgPicture.asset('assets/icons/Like.svg',width: size,height: size,);
      case Reaction.celebrate:
        return SvgPicture.asset('assets/icons/Celebrate.svg',width: size,height: size,);
      case Reaction.support:
        return SvgPicture.asset('assets/icons/Support.svg',width: size,height: size,);
      case Reaction.love:
        return SvgPicture.asset('assets/icons/Love.svg',width: size,height: size,);
      case Reaction.insightful:
        return SvgPicture.asset('assets/icons/Insightful.svg',width: size,height: size,);
      case Reaction.funny:
        return SvgPicture.asset('assets/icons/Funny.svg',width: size,height: size,);
      case Reaction.none:
        return Icon(Icons.thumb_up_alt_outlined,size: size,);
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
        return AppColors.funnyBlue;
      case Reaction.none:
        return null;
    }
  }
}



enum ActitvityType {
  repost,
  comment,
  like,
  celebrate,
  support,
  love,
  insightful,
  funny,
  none;

  static ActitvityType getActivityType(String activityType) {
    switch (activityType) {
      case 'repost':
        return ActitvityType.repost;
      case 'comment':
        return ActitvityType.comment;
      case 'like':
        return ActitvityType.like;
      case 'celebrate':
        return ActitvityType.celebrate;
      case 'support':
        return ActitvityType.support;
      case 'love':
        return ActitvityType.love;
      case 'insightful':
        return ActitvityType.insightful;
      case 'funny':
        return ActitvityType.funny;
      default:
        return ActitvityType.none;
    }
  }

  static String getActivityTypeString(ActitvityType activityType) {
    switch (activityType) {
      case ActitvityType.repost:
        return ' reposted this post';
      case ActitvityType.comment:
        return ' commented on this post';
      case ActitvityType.like:
        return ' likes this post';
      case ActitvityType.celebrate:
        return ' celebrates this post';
      case ActitvityType.support:
        return ' supports this post';
      case ActitvityType.love:
        return ' loves this post';
      case ActitvityType.insightful:
        return ' finds this post insightful';
      case ActitvityType.funny:
        return ' finds this post funny';
      default:
        return 'none';
    }
  }

}
