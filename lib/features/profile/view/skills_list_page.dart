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
    return FullListPage<SkillModel>( 
      pageTitle: "Skills",
      dataProvider: skillsDataProvider, 
      itemBuilder: (item, isDarkMode, context, isMyProfile) => SkillListItem( 
        skill: item,
        isDarkMode: isDarkMode,
        showActions: isMyProfile,
      ),
      
      addRoute: '/add_new_skill',
      editRoute: '/edit_skills_list', 
      emptyListMessage: "No skills added yet.\nTap '+' to add your first skill.", 
    );
  }
}