import 'package:flutter/foundation.dart' show immutable;
import 'package:link_up/features/profile/model/profile_model.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

// Initial state before any data is fetched
@immutable
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

// State when data is being fetched from the service
@immutable
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// State when the profile data has been successfully loaded
@immutable
class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  const ProfileLoaded(this.userProfile);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileLoaded &&
          runtimeType == other.runtimeType &&
          userProfile == other.userProfile;

  @override
  int get hashCode => userProfile.hashCode;
}

// State when an error occurred during data fetching
@immutable
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

   @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}