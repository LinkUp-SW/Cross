
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';

class UserDataViewModel {
  String userId;
  String profileUrl;

  UserDataViewModel({
    required this.userId,
    required this.profileUrl,
  });

  UserDataViewModel copyWith({
    String? userId,
    String? profileUrl,
  }) {
    return UserDataViewModel(
      userId: userId ?? this.userId,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  UserDataViewModel.initial()
      : userId = 'userId',
        profileUrl = 'profileUrl';

  
}

class UserNotifier extends StateNotifier<UserDataViewModel> {
  UserNotifier() : super(UserDataViewModel.initial());

  void updateUserData(String newUserId, String newProfileUrl) {
    state = UserDataViewModel(
      userId: newUserId,
      profileUrl: newProfileUrl,
    );
  }

  void setUserId(String newUserId) {
    state = state.copyWith(userId: newUserId);
  }

  Future<void> getProfileUrl() async {
    final BaseService baseService = BaseService();
    final response = await baseService.get('/profile/profile-picture/:user_id',
        routeParameters: {'user_id': state.userId});
    if(response.statusCode == 200) {
      state = state.copyWith(profileUrl: jsonDecode(response.body)['profilePicture']);
    } else {
      state = state.copyWith(profileUrl: 'https://i.pravatar.cc/300?img=52');
    }
    
  }

}

final userDataProvider = StateNotifierProvider<UserNotifier, UserDataViewModel>(
  (ref) => UserNotifier(),
);


