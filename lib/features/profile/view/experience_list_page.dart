import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/view/full_list_page.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/experience_list_widget.dart';

class ExperienceListPage extends ConsumerWidget {
  const ExperienceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullListPage<PositionModel>( 
      pageTitle: "Experience",
      dataProvider: experienceDataProvider, 
      itemBuilder: (item, isDarkMode, context, isMyProfile) => ExperienceListItem(
        exp: item,
        isDarkMode: isDarkMode,
        showActions: isMyProfile,
      ),
      addRoute: '/add_new_position', 
      editRoute: '/edit_experience_list', 
      emptyListMessage: "No experience added yet.\nTap '+' to add your first position.", 
    );
  }
}