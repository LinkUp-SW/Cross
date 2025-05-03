import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/settings/viewModel/privacy_settings_vm.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/theme_provider.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 5,
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          spacing: 5.h,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  InternalEndPoints.profileUrl,
                ),
              ),
              title: const Text('Settings',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'Account Preferences',
              ),
              onTap: () {
                showModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        ThemeMode theme = ref.watch(themeNotifierProvider);
                        return CustomModalBottomSheet(
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text("Display",
                                    style: TextStyle(
                                        fontSize: 20.r,
                                        fontWeight: FontWeight.bold)),
                              ),
                              RadioListTile(
                                  value: ThemeMode.system,
                                  title: Text("Device Settings"),
                                  activeColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  groupValue: theme,
                                  onChanged: (value) {
                                    ref
                                        .read(themeNotifierProvider.notifier)
                                        .setTheme(value!);
                                    setState(
                                      () {},
                                    );
                                  }),
                              RadioListTile(
                                  value: ThemeMode.light,
                                  title: Text("Light Mode"),
                                  activeColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  groupValue: theme,
                                  onChanged: (value) {
                                    ref
                                        .read(themeNotifierProvider.notifier)
                                        .setTheme(value!);
                                    setState(
                                      () {},
                                    );
                                  }),
                              RadioListTile(
                                  value: ThemeMode.dark,
                                  title: Text("Dark Mode"),
                                  activeColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  groupValue: theme,
                                  onChanged: (value) {
                                    ref
                                        .read(themeNotifierProvider.notifier)
                                        .setTheme(value!);
                                    setState(
                                      () {},
                                    );
                                  }),
                            ],
                          ),
                        );
                      });
                    });
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text(
                'Sign in and Security',
              ),
              onTap: () {
                //TODO: implement sign in and security functionality
                context.push('/settings/security');
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text(
                'Privacy Settings',
              ),
              onTap: () {
                ref
                    .read(privacySettingsVmProvider.notifier)
                    .getPrivacySettings()
                    .then((value) {
                  if (context.mounted) {
                    context.push('/settings/privacy');
                  }
                });
              },
            ),
            ListTile(
              leading: Image(
                image: AssetImage('assets/images/linkup_premium.png'),
                width: 20.w,
                height: 20.h,
              ),
              title: const Text('Subscription Management'),
              onTap: () {
                context.push('/payment');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppColors.red,
              ),
              title: const Text(
                'Log out',
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          elevation: 10,
                          title: const Text('Log out'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                                onPressed: () {
                                  logout(context);
                                },
                                child: const Text(
                                  'Log out',
                                  style: TextStyle(color: AppColors.red),
                                ))
                          ]);
                    });
              },
            ),
            ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: AppColors.red,
                ),
                title: const Text(
                  'Delete account',
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            elevation: 10,
                            title: const Text('Delete account'),
                            content: const Text(
                                'Are you sure you want to delete your account? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    final BaseService baseService =
                                        BaseService();
                                    final response = await baseService.delete(
                                        'api/v1/user/delete-account', null);
                                    log(response.body.toString());
                                    if (context.mounted &&
                                        response.statusCode == 200) {
                                      logout(context);
                                    }
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.red),
                                  ))
                            ]);
                      });
                }),
          ],
        ),
      ),
    );
  }
}
