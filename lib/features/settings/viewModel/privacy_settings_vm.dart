import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/home_enums.dart';

class PrivacySettingsVm {
  Visibilities profileVisibility = Visibilities.anyone;
  Visibilities invitationRequests = Visibilities.anyone;
  Visibilities followRequest = Visibilities.anyone;
  bool followPrimary = false;
  bool messagingRequest = false;
  bool readReciepts = false;
  final BaseService baseService = BaseService();
}

class PrivacySettingsVmNotifier extends StateNotifier<PrivacySettingsVm> {
  PrivacySettingsVmNotifier() : super(PrivacySettingsVm());

  Future<void> getPrivacySettings() async {
    // Fetch initial data from the API and update the state
    await state.baseService.get('api/v1/user/privacy-settings').then((value) {
      if (value.statusCode == 200) {
        final data = jsonDecode(value.body);
        log(data.toString());
        // Handle success
        state.profileVisibility = data['profileVisibility'] == 'Public'
            ? Visibilities.anyone
            : Visibilities.connectionsOnly;
        state.invitationRequests = data['invitationSetting'] == 'Everyone'
            ? Visibilities.anyone
            : Visibilities.connectionsOnly;
        state.followRequest = data['followSetting'] == 'Everyone'
            ? Visibilities.anyone
            : Visibilities.connectionsOnly;
        state.followPrimary = data['isFollowPrimary'];
        state.messagingRequest = data['messagingRequests'];
        state.readReciepts = data['readReceipts'];
      } else {
        // Handle error
      }
    });
  }

  Future<void> setProfileVisibility(Visibilities visibility) async {
    //Public or Private
    await state.baseService.put('api/v1/user/privacy-settings/profile-visibility', {
      'profileVisibility':
          visibility == Visibilities.anyone ? 'Public' : 'Connections only',
    }).then((value) {
      if (value.statusCode == 200) {
        // Handle success
        state.profileVisibility = visibility;
        log(value.body.toString());
      } else {
        // Handle error
        log('Error: ${value.statusCode}');
      }
    });
  }

  Future<void> setInvitationRequests(Visibilities visibility) async{
    //Everyone or email
    await state.baseService.put('api/v1/user/privacy-settings/invitations-requests', {
      'invitationSetting':
          visibility == Visibilities.anyone ? 'Everyone' : 'email',
    }).then((value) {
      if (value.statusCode == 200) {
        // Handle success
        state.invitationRequests = visibility;
        log(value.body.toString());
      } else {
        // Handle error
      }
    });
  }

  Future<void> setFollowRequest(Visibilities visibility) async {
    //Everyone or connections only
    await state.baseService.put('api/v1/user/privacy-settings/follow-requests', {
      'followSetting':
          visibility == Visibilities.anyone ? 'Everyone' : 'Connections only',
    }).then((value) {
      if (value.statusCode == 200) {
        // Handle success
        state.followRequest = visibility;
        log(value.body.toString());
      } else {
        // Handle error
      }
    });
  }

  Future<void> setFollowPrimary(bool setting) async{
    await state.baseService.put('api/v1/user/privacy-settings/follow-primary', {
      'isFollowPrimary': setting,
    }).then((value) {
      if (value.statusCode == 200) {
        // Handle success
        state.followPrimary = setting;
        log(value.body.toString());
      } else {
        // Handle error
      }
    });
  }

  Future<void> setMessagingRequest(bool setting) async{
    await state.baseService.put('api/v1/user/privacy-settings/messaging-requests', {
      'messagingRequests': setting,
    }).then((value) {
      if (value.statusCode == 200) {
        // Handle success
        state.messagingRequest = setting;
        log(value.body.toString());
      } else {
        // Handle error
      }
    });
  }

  Future<void> setReadReciepts(bool setting) async{
    await state.baseService.put('api/v1/user/privacy-settings/read-receipts', {
      'readReceipts': setting,
    }).then((value) {
      if (value.statusCode == 200) {
        // Handle success
        state.readReciepts = setting;
        log(value.body.toString());
      } else {
        // Handle error
      }
    });
  }
}

final privacySettingsVmProvider =
    StateNotifierProvider<PrivacySettingsVmNotifier, PrivacySettingsVm>(
  (ref) => PrivacySettingsVmNotifier(),
);
