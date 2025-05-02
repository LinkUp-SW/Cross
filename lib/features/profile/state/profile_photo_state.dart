import 'dart:io';
import 'package:flutter/foundation.dart' show immutable;
import 'package:image_picker/image_picker.dart';

@immutable
sealed class ProfilePhotoState {
  const ProfilePhotoState();
}

class ProfilePhotoInitial extends ProfilePhotoState {
  const ProfilePhotoInitial();
}

class ProfilePhotoSelected extends ProfilePhotoState {
  final XFile imageFile;
  const ProfilePhotoSelected(this.imageFile);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfilePhotoSelected && other.imageFile.path == imageFile.path;
  }
  @override
  int get hashCode => imageFile.path.hashCode;
}

class ProfilePhotoUploading extends ProfilePhotoState {
   final XFile imageFile;
   const ProfilePhotoUploading(this.imageFile);

   @override
   bool operator ==(Object other) {
     if (identical(this, other)) return true;
     return other is ProfilePhotoUploading && other.imageFile.path == imageFile.path;
   }
   @override
   int get hashCode => imageFile.path.hashCode;
}

class ProfilePhotoDeleting extends ProfilePhotoState {
   const ProfilePhotoDeleting();
}

class ProfilePhotoSuccess extends ProfilePhotoState {
  final String newImageUrl; 
  const ProfilePhotoSuccess(this.newImageUrl);

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfilePhotoSuccess && other.newImageUrl == newImageUrl;
  }
  @override
  int get hashCode => newImageUrl.hashCode;
}

class ProfilePhotoError extends ProfilePhotoState {
  final String message;
  const ProfilePhotoError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfilePhotoError && other.message == message;
  }
  @override
  int get hashCode => message.hashCode;
}