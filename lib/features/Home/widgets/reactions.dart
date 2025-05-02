

import 'package:flutter/material.dart';
import 'package:link_up/features/Home/home_enums.dart';

class Reactions extends StatefulWidget {
  final Reaction reaction;
  final Function setReaction;
  final Widget child;
  final double offset;
  const Reactions(
      {super.key,
      required this.reaction,
      required this.setReaction,
      required this.child,
      required this.offset});

  @override
  State<Reactions> createState() => _ReactionsState();
}

class _ReactionsState extends State<Reactions> with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  bool _selected = false;
  Offset _offset = Offset.zero;
  late Reaction reaction = widget.reaction;

  final List<GlobalKey<TooltipState>> _tooltipKeys = Reaction.values.sublist(0, 6)
      .map((reaction) => GlobalKey<TooltipState>())
      .toList();

  @override
  Widget build(BuildContext context) {
    final targetRenderBox = context.findRenderObject() as RenderBox?;
    final position = targetRenderBox == null
        ? const Offset(0, 0)
        : targetRenderBox.localToGlobal(Offset.zero);
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return StatefulBuilder(builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _overlayController.hide();
                },
                onVerticalDragUpdate: (details) {
                  _overlayController.hide();
                },
              ),
              Positioned(
                top: position.dy - widget.offset,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Wrap(
                            spacing: 5,
                            children: [
                              for (var i = 0;
                                  i < Reaction.values.length - 1;
                                  i++) ...[
                                Tooltip(
                                  triggerMode: TooltipTriggerMode.manual,
                                  preferBelow: false,
                                  enableFeedback: true,
                                  key: _tooltipKeys[i],
                                  showDuration: const Duration(seconds: 1),
                                  message: Reaction.getReactionString(
                                      Reaction.values[i]),
                                  child: AnimatedScale(
                                    scale: !_selected
                                        ? 1.0
                                        : _offset.dx > i * 40 + 60 &&
                                                _offset.dx <
                                                    (i + 1) * 40 + 60
                                            ? 1.5
                                            : 0.8,
                                    duration:
                                        const Duration(milliseconds: 200),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            reaction = Reaction.values[i];
                                          });
                                          widget.setReaction(reaction);
                                        },
                                        child: Reaction.getIcon(
                                            Reaction.values[i], 40)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
      },
      child: GestureDetector(
        onLongPressMoveUpdate: (details) {
          if (details.offsetFromOrigin.dy < 0 &&
              details.offsetFromOrigin.dy > -100) {
            setState(() {
              _selected = true;
              _offset = details.globalPosition;
              Tooltip.dismissAllToolTips();
              for (var i = 0; i < Reaction.values.length - 1; i++) {
                if (_offset.dx > i * 40 + 60 &&
                    _offset.dx < (i + 1) * 40 + 60) {
                  _tooltipKeys[i].currentState?.ensureTooltipVisible();
                  reaction = Reaction.values[i];
                }
              }
            });
          } else {
            setState(() {
              _selected = false;
              reaction = widget.reaction;
            });
          }
        },
        onLongPress: () {
          _overlayController.show();
        },
        onLongPressUp: () {
          setState(() {
            _selected = false;
          });
          widget.setReaction(reaction);
          Future.delayed(const Duration(milliseconds: 1000), () {
            _overlayController.hide();
          });
        },
        onTap: () {
          setState(() {
            reaction =
                reaction == Reaction.none ? Reaction.like : Reaction.none;
          });
          widget.setReaction(reaction);
        },
        child: widget.child,
      ),
    );
  }
}
