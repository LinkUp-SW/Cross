import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/view/full_list_page.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/license_list_widget.dart'; 

class LicenseListPage extends ConsumerWidget {
  const LicenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullListPage<LicenseModel>( 
      pageTitle: "Licenses & Certifications",
      dataProvider: licenseDataProvider, 

      itemBuilder: (item, isDarkMode, context) => LicenseListItem(
        license: item,
        isDarkMode: isDarkMode,
      ),
      addRoute: '/add_new_license', 
      editRoute: '/edit_licenses_list', 
      emptyListMessage: "No licenses or certifications added yet.\nTap '+' to add your first one.", 
    );
  }
}