
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/services/image_picker_service.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/profile_photo_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/core/constants/endpoints.dart';

class ProfilePhotoViewModel extends StateNotifier<ProfilePhotoState> {
  final Ref _ref;

  ProfilePhotoViewModel(this._ref) : super(const ProfilePhotoInitial());

  ImagePickerService get _imagePickerService => _ref.read(imagePickerServiceProvider);
  ProfileService get _profileService => _ref.read(profileServiceProvider);
  String get _userId => InternalEndPoints.userId;

  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final imageFile = await _imagePickerService.pickImage(source);
      if (imageFile != null) {
        if (mounted) {
           state = ProfilePhotoSelected(imageFile);
           await uploadProfilePhoto();
        }
      } else {
         if (mounted) {
           state = const ProfilePhotoInitial();
         }
      }
    } catch (e) {
      log("ViewModel: Error picking image: $e");
      if (mounted) {
        state = ProfilePhotoError("Failed to pick image: ${e.toString()}");
      }
    }
  }

  Future<void> uploadProfilePhoto() async {
    if (state is! ProfilePhotoSelected) {
      log("ViewModel: No photo selected to upload.");
      return;
    }
    if (_userId.isEmpty) {
       state = const ProfilePhotoError("Cannot upload photo: User not logged in.");
       return;
    }

    final imageFile = (state as ProfilePhotoSelected).imageFile;
    if (mounted) {
       state = ProfilePhotoUploading(imageFile);
    }

    try {
      final bool uploadSuccessful = await _profileService.updateProfilePhoto(imageFile);

      if (uploadSuccessful && mounted) {
         log("ViewModel: Upload reported success by service.");
         try {
            final String fetchedImageUrl = await _profileService.getProfilePhotoUrl(_userId);

            if (mounted) {
              state = ProfilePhotoSuccess(fetchedImageUrl);
              log("ViewModel: Fetched new URL successfully: $fetchedImageUrl");
              _ref.read(profileViewModelProvider.notifier).updateProfilePhotoUrl(fetchedImageUrl);
            }
         } catch (fetchError) {
             log("ViewModel: Error fetching photo URL after successful upload: $fetchError");
             if (mounted) {
               state = ProfilePhotoError("Photo uploaded, but failed to refresh URL: ${fetchError.toString()}");
             }
         }
      } else if (mounted) {
         log("ViewModel: Upload failed (service returned false or component unmounted).");
         state = const ProfilePhotoError("Failed to upload photo.");
      }
    } catch (e) {
      log("ViewModel: Error during upload process: $e");
      if (mounted) {
        state = ProfilePhotoError("Failed to upload photo: ${e.toString()}");
      }
    }
  }

   Future<void> deleteProfilePhoto() async {
     if (_userId.isEmpty) {
        state = const ProfilePhotoError("Cannot delete photo: User not logged in.");
        return;
     }

     if (mounted) {
        state = const ProfilePhotoDeleting();
     }

     try {
        final bool deleteSuccess = await _profileService.deleteProfilePhoto();

        if (deleteSuccess && mounted) {
           log("ViewModel: Delete reported success by service.");
           _ref.read(profileViewModelProvider.notifier).updateProfilePhotoUrl("");
           state = const ProfilePhotoSuccess("");
           log("ViewModel: Profile photo deleted successfully.");

           await Future.delayed(const Duration(milliseconds: 500));
           if (mounted) {
              state = const ProfilePhotoInitial();
           }

        } else if(mounted) {
           log("ViewModel: Delete failed (service returned false or component unmounted).");
           state = const ProfilePhotoError("Failed to delete photo.");
        }

     } catch (e) {
        log("ViewModel: Error during delete process: $e");
        if (mounted) {
          state = ProfilePhotoError("Failed to delete photo: ${e.toString()}");
        }
     }
   }

   void showImageSourceDialog(BuildContext context) {
     showModalBottomSheet(
       context: context,
       builder: (BuildContext context) {
         return SafeArea(
           child: Wrap(
             children: <Widget>[
               ListTile(
                 leading: const Icon(Icons.camera_alt),
                 title: const Text('Take Photo'),
                 onTap: () {
                   Navigator.pop(context);
                   pickProfilePhoto(ImageSource.camera);
                 },
               ),
               ListTile(
                 leading: const Icon(Icons.photo_library),
                 title: const Text('Choose From Gallery'),
                 onTap: () {
                   Navigator.pop(context);
                   pickProfilePhoto(ImageSource.gallery);
                 },
               ),
             ],
           ),
         );
       },
     );
   }

   void resetState() {
      state = const ProfilePhotoInitial();
   }
}

final profilePhotoViewModelProvider =
    StateNotifierProvider.autoDispose<ProfilePhotoViewModel, ProfilePhotoState>(
        (ref) {
  return ProfilePhotoViewModel(ref);
});