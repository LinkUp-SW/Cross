import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/reaction_tile_model.dart';
import 'package:link_up/shared/themes/colors.dart';

class ReactionsPage extends StatefulWidget {
  const ReactionsPage({super.key});

  @override
  State<ReactionsPage> createState() => _ReactionsPageState();
}

class _ReactionsPageState extends State<ReactionsPage> {
  List<ReactionTileModel> reactions = List.generate(100, (index) {
    return ReactionTileModel.fromJson(jsonDecode('''
      {
        "header": {
          "profileImage": "https://i.pravatar.cc/150?img=$index",
          "name": "User $index",
          "connectionDegree": "1st",
          "about": "About user $index",
          "timeAgo": "${DateTime.now()}"
        },
        "reaction": "${Reaction.getReactionString(Reaction.values[index % Reaction.values.length])}"
      }
    '''));
  });

  late final Map<String, int> reactionsCount;

  @override
  void initState() {
    super.initState();
    reactionsCount = {
      for (var reaction in Reaction.values)
        if (reaction != Reaction.none)
          Reaction.getReactionString(reaction):
            reactions.where((element) => element.reaction == reaction).length
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: reactionsCount.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reactions'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          bottom: TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelColor: Theme.of(context).colorScheme.tertiary,
              indicatorColor: Theme.of(context).colorScheme.tertiary,
              dividerColor: AppColors.grey,
              tabs: [
                Tab(
                  child: Text('All  ${reactions.length}',
                      textAlign: TextAlign.center),
                ),
                for (var reaction in reactionsCount.keys)
                  Tab(
                    icon: Row(
                      children: [
                        Reaction.getIcon(Reaction.getReaction(reaction)),
                        Text(
                          '  ${reactionsCount[reaction].toString()}',
                        ),
                      ],
                    ),
                  ),
              ]),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: reactions.length,
              itemBuilder: (context, index) {
                return ReactionTile(
                  reactionTile: reactions[index],
                );
              },
            ),
            ...reactionsCount.keys
                .map((reaction) => reactions.where((element) =>
                    element.reaction == Reaction.getReaction(reaction)))
                .map((entry) {
              return ListView.builder(
                itemCount: entry.length,
                itemBuilder: (context, index) {
                  return ReactionTile(
                    reactionTile: entry.toList()[index],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ReactionTile extends StatelessWidget {
  const ReactionTile({super.key, required this.reactionTile});

  final ReactionTileModel reactionTile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.primary,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: NetworkImage(reactionTile.header.profileImage),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 11.r,
              backgroundColor: Reaction.getColor(reactionTile.reaction),
              child: Icon(
                Reaction.getIconData(
                  reactionTile.reaction,
                ),
                color: AppColors.lightBackground,
                size: 15.r,
              ),
            ),
          ),
        ],
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: reactionTile.header.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: ' • ${reactionTile.header.connectionDegree}',
              style: TextStyle(color: AppColors.grey, fontSize: 10.r),
            ),
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reactionTile.header.about,
              style: const TextStyle(color: AppColors.grey)),
          const Divider(
            color: AppColors.grey,
            thickness: 0,
          ),
        ],
      ),
    );
  }
}
