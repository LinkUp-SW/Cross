import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/settings/viewModel/privacy_settings_vm.dart';
import 'package:link_up/shared/themes/colors.dart';

class PrivacySettings extends ConsumerStatefulWidget {
  const PrivacySettings({super.key});

  @override
  ConsumerState<PrivacySettings> createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends ConsumerState<PrivacySettings> {
  @override
  Widget build(BuildContext context) {
    final privacySettings = ref.watch(privacySettingsVmProvider);
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
          spacing: 5,
          children: [
            ListTile(
              dense: true,
              title: Text("Profile Visibility",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              trailing: DropdownButton(
                  value: privacySettings.profileVisibility,
                  items: [Visibilities.anyone, Visibilities.connectionsOnly]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == Visibilities.anyone
                                ? "Public"
                                : "Connections Only"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    ref
                        .read(privacySettingsVmProvider.notifier)
                        .setProfileVisibility(value!)
                        .then((_) {
                      setState(() {});
                    });
                  }),
            ),
            ListTile(
              dense: true,
              title: Text("Invitation Requests",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              trailing: DropdownButton(
                  value: privacySettings.invitationRequests,
                  items: [Visibilities.anyone, Visibilities.connectionsOnly]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == Visibilities.anyone
                                ? "Everyone"
                                : "Email"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    ref
                        .read(privacySettingsVmProvider.notifier)
                        .setInvitationRequests(value!)
                        .then((_) {
                      setState(() {});
                    });
                  }),
            ),
            ListTile(
              dense: true,
              title: Text("Follow Requests",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              trailing: DropdownButton(
                  value: privacySettings.followRequest,
                  items: [Visibilities.anyone, Visibilities.connectionsOnly]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == Visibilities.anyone
                                ? "Everyone"
                                : "Connections Only"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    ref
                        .read(privacySettingsVmProvider.notifier)
                        .setFollowRequest(value!)
                        .then((_) {
                      setState(() {});
                    });
                  }),
            ),
            SwitchListTile(
              value: privacySettings.followPrimary,
              onChanged: (value) {
                ref
                    .read(privacySettingsVmProvider.notifier)
                    .setFollowPrimary(value)
                    .then((_) {
                  setState(() {});
                });
              },
              title: Text("Follow Primary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              subtitle: Text(
                  "The follow button will be the primary (instead of connect button)",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  )),
              activeColor: Theme.of(context).colorScheme.tertiary,
            ),
            SwitchListTile(
              value: privacySettings.messagingRequest,
              onChanged: (value) {
                ref
                    .read(privacySettingsVmProvider.notifier)
                    .setMessagingRequest(value)
                    .then((_) {
                  setState(() {});
                });
              },
              title: Text("Messaging Requests",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              subtitle: Text(
                  "Users who are not connections can send message requests",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  )),
              activeColor: Theme.of(context).colorScheme.tertiary,
            ),
            SwitchListTile(
              value: privacySettings.readReciepts,
              onChanged: (value) {
                ref
                    .read(privacySettingsVmProvider.notifier)
                    .setReadReciepts(value)
                    .then((_) {
                  setState(() {});
                });
              },
              title: Text("Read Reciepts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              subtitle: Text("Allow others to see when you read their messages",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  )),
              activeColor: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
