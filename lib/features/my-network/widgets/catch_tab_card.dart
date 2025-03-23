import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/model.dart';

class CatchTabCard extends ConsumerWidget {
  final CatchTabCardsModel data;
  final bool isDarkMode;
  const CatchTabCard({
    super.key,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox();
  }
}
