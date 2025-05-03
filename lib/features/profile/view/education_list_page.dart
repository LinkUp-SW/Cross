import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/view/full_list_page.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/education_list_widget.dart'; 

class EducationListPage extends ConsumerWidget {
  const EducationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullListPage<EducationModel>( 
      pageTitle: "Education",
      dataProvider: educationDataProvider, 
      itemBuilder: (item, isDarkMode, context) => EducationListItem(
        education: item,
        isDarkMode: isDarkMode,
        showActions: true,
      ),
      addRoute: '/add_new_education', 
      editRoute: '/edit_education_list', 
      emptyListMessage: "No education added yet.\nTap '+' to add your first school.", 
    );
  }
}