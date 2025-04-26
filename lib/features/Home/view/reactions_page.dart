import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/reaction_tile_model.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/shared/themes/colors.dart';

class ReactionsPage extends ConsumerStatefulWidget {
  const ReactionsPage({super.key});

  @override
  ConsumerState<ReactionsPage> createState() => _ReactionsPageState();
}

class _ReactionsPageState extends ConsumerState<ReactionsPage> {
  late Map<String, int> reactionsCount = {};
  late Map<String, List<ReactionTileModel>> reactions = {};

  @override
  void initState() {
    super.initState();
    intialLoad();
  }

  Future<void> intialLoad() async {
    reactions = await ref.read(postProvider.notifier).fetchReactions();
    setState(() {
      reactionsCount = {
        for (var reaction in reactions.keys)
          reaction: reactions[reaction]!.length
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: reactionsCount.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Reactions'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          bottom: reactions.isEmpty
              ? null
              : TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.tertiary,
                  indicatorColor: Theme.of(context).colorScheme.tertiary,
                  dividerColor: AppColors.grey,
                  tabs: [
                      Tab(
                        child: Text('All  ${reactionsCount['All'].toString()}',
                            textAlign: TextAlign.center),
                      ),
                      for (var reaction in reactionsCount.keys)
                        if (reaction != 'All')
                          Tab(
                            icon: Row(
                              children: [
                                Reaction.getIcon(
                                    Reaction.getReaction(reaction), 20.r),
                                Text(
                                  '  ${reactionsCount[reaction].toString()}',
                                ),
                              ],
                            ),
                          ),
                    ]),
        ),
        body: reactions.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkBlue,
                ),
              )
            : TabBarView(
                children: [
                  ...reactions.keys.map((reaction) => ListView.builder(
                        itemCount: reactions[reaction]!.length,
                        itemBuilder: (context, index) {
                          return ReactionTile(
                            reactionTile: reactions[reaction]!.elementAt(index),
                          );
                        },
                      ))
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
            child: Reaction.getIcon(reactionTile.reaction, 25.r),
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
