
import 'package:flutter/foundation.dart' show immutable;
import 'package:image_picker/image_picker.dart';

@immutable
sealed class CoverPhotoState {
  const CoverPhotoState();
}

class CoverPhotoInitial extends CoverPhotoState {
  const CoverPhotoInitial();
}

class CoverPhotoSelected extends CoverPhotoState {
  final XFile imageFile;
  const CoverPhotoSelected(this.imageFile);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverPhotoSelected && other.imageFile.path == imageFile.path;
  }
  @override
  int get hashCode => imageFile.path.hashCode;
}

class CoverPhotoUploading extends CoverPhotoState {
   final XFile imageFile;
   const CoverPhotoUploading(this.imageFile);

   @override
   bool operator ==(Object other) {
     if (identical(this, other)) return true;
     return other is CoverPhotoUploading && other.imageFile.path == imageFile.path;
   }
   @override
   int get hashCode => imageFile.path.hashCode;
}

class CoverPhotoDeleting extends CoverPhotoState {
   const CoverPhotoDeleting();
}

class CoverPhotoSuccess extends CoverPhotoState {
  final String newImageUrl; // Can be empty string after deletion
  const CoverPhotoSuccess(this.newImageUrl);

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverPhotoSuccess && other.newImageUrl == newImageUrl;
  }
  @override
  int get hashCode => newImageUrl.hashCode;
}

class CoverPhotoError extends CoverPhotoState {
  final String message;
  const CoverPhotoError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverPhotoError && other.message == message;
  }
  @override
  int get hashCode => message.hashCode;
}