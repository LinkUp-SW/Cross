import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/reaction_tile_model.dart';
import 'package:link_up/features/Home/viewModel/reactions_vm.dart';
import 'package:link_up/shared/themes/colors.dart';

class ReactionsPage extends ConsumerStatefulWidget {
  const ReactionsPage({super.key});

  @override
  ConsumerState<ReactionsPage> createState() => _ReactionsPageState();
}

class _ReactionsPageState extends ConsumerState<ReactionsPage> {
  bool isLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    intialLoad();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        final reactionsCount = ref.watch(reactionsProvider).reactionsCount;
        final cursors = ref.watch(reactionsProvider).cursor;
        for (var reaction in reactionsCount.keys) {
          if (cursors[reaction] != null) {
            getMoreReactions(reaction);
          }
        }
      }
    });
  }

  Future<void> intialLoad() async {
    setState(() {
      isLoading = true;
    });
    await ref.read(reactionsProvider.notifier).fetchReactions(Reaction.none);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getMoreReactionsAll() async {
    await ref.read(reactionsProvider.notifier).fetchReactions(Reaction.none);
    setState(() {});
  }

  Future<void> getMoreReactions(Reaction reaction) async {
    await ref.read(reactionsProvider.notifier).fetchReactions(reaction);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final reactions = ref.watch(reactionsProvider).reactions;
    final reactionsCount = ref.watch(reactionsProvider).reactionsCount;
    final cursors = ref.watch(reactionsProvider).cursor;

    return DefaultTabController(
      length: reactionsCount.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Reactions'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            onPressed: () {
              ref.read(reactionsProvider.notifier).clear();
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
              onTap: (index) {
                // Handle tab switching
                Reaction? selectedReaction;
                if (index == 0) {
                  selectedReaction = null; // All reactions
                } else {
                  // Get the specific reaction type from the keys, skipping the first one (Reaction.none)
                  final reactionsList = reactionsCount.keys.toList();
                  selectedReaction = reactionsList[index];
                }

                // Fetch reactions based on selected tab
                if (selectedReaction == null) {
                  if (cursors[Reaction.none] != null) {
                    getMoreReactionsAll();
                  }
                } else {
                  if (cursors[selectedReaction] != null) {
                    getMoreReactions(selectedReaction);
                  }
                }
              },
              tabs: [
                Tab(
                  child: Text(
                      'All  ${reactionsCount[Reaction.none].toString()}',
                      textAlign: TextAlign.center),
                ),
                for (var reaction in reactionsCount.keys)
                  if (reaction != Reaction.none)
                    Tab(
                      icon: Row(
                        children: [
                          Reaction.getIcon(reaction, 20.r),
                          Text(
                            '  ${reactionsCount[reaction].toString()}',
                          ),
                        ],
                      ),
                    ),
              ]),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
            : TabBarView(
                children: [
                  for (var reaction in reactionsCount.keys)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.grey,
                          thickness: 0,
                        ),
                        controller: scrollController,
                        itemCount: reactions[reaction]!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ReactionTile(
                            reactionTile: reactions[reaction]!.elementAt(index),
                          );
                        },
                      ),
                    ),
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
      subtitle: reactionTile.header.about == ''
          ? const SizedBox()
          : Text(reactionTile.header.about,
              style: const TextStyle(color: AppColors.grey)),
    );
  }
}
