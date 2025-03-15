import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/shared/themes/colors.dart';

class Reactions extends StatefulWidget {
  const Reactions({super.key});

  @override
  State<Reactions> createState() => _ReactionsState();
}

class _ReactionsState extends State<Reactions> {
  Offset? _tapPosition;
  Reaction _reaction = Reaction.none;

  Future<void> _showCustomMenu() async {
    if (_tapPosition == null) {
      return;
    }
    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) {
      return;
    }

    final menu = await showMenu(
      context: context,
      constraints: BoxConstraints(
        maxWidth: 300.w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.r),
      ),
      elevation: 10,
      color: Theme.of(context).colorScheme.primary,
      position: RelativeRect.fromRect(
          _tapPosition! & Size(40.r, 40.r), // smaller rect, the touch area
          Offset(0, 100.h) &
              overlay.semanticBounds.size // Bigger rect, the entire screen
          ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              SizedBox(
                width: 10.w,
              ),
              for (var i = 0; i < Reaction.values.length - 1; i++) ...[
                IconButton(
                    tooltip: Reaction.values[i].name,
                    onPressed: () {
                      setState(() {
                        _reaction = Reaction.values[i];
                      });
                    },
                    icon: Reaction.getIcon(Reaction.values[i])),
              ],
            ],
          ),
        ),
      ],
    );
    if (menu == null) {
      return;
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // This does not give the tap position ...
      onLongPress: _showCustomMenu,

      // Have to remember it on tap-down.
      onTapDown: _storePosition,

      onTap: () {
        setState(() {
          _reaction =
              _reaction == Reaction.none ? Reaction.like : Reaction.none;
        });
      },

      child: Column(
        children: [
          Reaction.getIcon(_reaction),
          Text(
            switch (_reaction) {
              Reaction.like => 'Like',
              Reaction.love => 'Love',
              Reaction.insightful => 'Insightful',
              Reaction.funny => 'Funny',
              Reaction.celebrate => 'Celebrate',
              Reaction.support => 'Support',
              Reaction.none => 'Like',
            },
            style: TextStyle(
              color: switch (_reaction) {
                Reaction.like => AppColors.darkBlue,
                Reaction.love => AppColors.red,
                Reaction.insightful => AppColors.amber,
                Reaction.funny => AppColors.lightBlue,
                Reaction.celebrate => Colors.green,
                Reaction.support => Colors.purple[300],
                Reaction.none => null,
              },
            ),
          )
        ],
      ),
    );
  }
}
