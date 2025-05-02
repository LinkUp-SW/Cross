import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/view/full_list_page.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/skills_list_widget.dart'; 

class SkillListPage extends ConsumerWidget {
  const SkillListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Return the generic page, configured for Skills
    return FullListPage<SkillModel>( // Specify the data type <SkillModel>
      pageTitle: "Skills",
      dataProvider: skillsDataProvider, // Provide the specific data provider
      // Provide the specific item builder widget instance
      itemBuilder: (item, isDarkMode, context) => SkillListItem( // SkillListItem is a ConsumerWidget, should still work here
        skill: item,
        isDarkMode: isDarkMode,
      ),
      addRoute: '/add_new_skill', // Route for the add button
      editRoute: '/edit_skills_list', // Route for the edit button (can be null if not implemented)
      emptyListMessage: "No skills added yet.\nTap '+' to add your first skill.", // Specific empty message
    );
  }
}