import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/model.dart';

class NewsletterCard extends ConsumerWidget {
  final GrowTabNewsletterCardsModel data;
  final bool isDarkMode;

  const NewsletterCard({
    super.key,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card();
  }
}
