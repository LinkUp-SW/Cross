import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/services/image_picker_service.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/cover_photo_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/widgets/bottom_sheet.dart';


class CoverPhotoViewModel extends StateNotifier<CoverPhotoState> {
  final Ref _ref;

  CoverPhotoViewModel(this._ref) : super(const CoverPhotoInitial());

  ImagePickerService get _imagePickerService => _ref.read(imagePickerServiceProvider);
  ProfileService get _profileService => _ref.read(profileServiceProvider);
  String get _userId => InternalEndPoints.userId;

  Future<void> pickCoverPhoto(ImageSource source) async {
    try {
      final imageFile = await _imagePickerService.pickImage(source);
      if (imageFile != null) {
        if (mounted) {
           state = CoverPhotoSelected(imageFile);
           await uploadCoverPhoto();
        }
      } else {
         if (mounted) {
           state = const CoverPhotoInitial();
         }
      }
    } catch (e) {
      log("ViewModel: Error picking cover photo: $e");
      if (mounted) {
        state = CoverPhotoError("Failed to pick cover photo: ${e.toString()}");
      }
    }
  }

  Future<void> uploadCoverPhoto() async {
    if (state is! CoverPhotoSelected) {
      log("ViewModel: No cover photo selected to upload.");
      return;
    }
    if (_userId.isEmpty) {
       state = const CoverPhotoError("Cannot upload cover photo: User not logged in.");
       return;
    }

    final imageFile = (state as CoverPhotoSelected).imageFile;
    if (mounted) {
       state = CoverPhotoUploading(imageFile);
    }

    try {
      final bool uploadSuccessful = await _profileService.updateCoverPhoto(imageFile);

      if (uploadSuccessful && mounted) {
         log("ViewModel: Cover photo upload reported success by service.");
         try {
            final String fetchedImageUrl = await _profileService.getCoverPhotoUrl(_userId);

            if (mounted) {
              state = CoverPhotoSuccess(fetchedImageUrl);
              log("ViewModel: Fetched new cover photo URL successfully: $fetchedImageUrl");
              _ref.read(profileViewModelProvider.notifier).updateCoverPhotoUrl(fetchedImageUrl);
            }
         } catch (fetchError) {
             log("ViewModel: Error fetching cover photo URL after successful upload: $fetchError");
             if (mounted) {
               state = CoverPhotoError("Cover photo uploaded, but failed to refresh URL: ${fetchError.toString()}");
             }
         }
      } else if (mounted) {
         log("ViewModel: Cover photo upload failed (service returned false or component unmounted).");
         state = const CoverPhotoError("Failed to upload cover photo.");
      }
    } catch (e) {
      log("ViewModel: Error during cover photo upload process: $e");
      if (mounted) {
        state = CoverPhotoError("Failed to upload cover photo: ${e.toString()}");
      }
    }
  }

   Future<void> deleteCoverPhoto() async {
     if (_userId.isEmpty) {
        state = const CoverPhotoError("Cannot delete cover photo: User not logged in.");
        return;
     }

     if (mounted) {
        state = const CoverPhotoDeleting();
     }

     try {
        final bool deleteSuccess = await _profileService.deleteCoverPhoto();

        if (deleteSuccess && mounted) {
           log("ViewModel: Cover photo delete reported success by service.");
           _ref.read(profileViewModelProvider.notifier).updateCoverPhotoUrl("");
           state = const CoverPhotoSuccess("");
           log("ViewModel: Cover photo deleted successfully.");

           await Future.delayed(const Duration(milliseconds: 500));
           if (mounted) {
              state = const CoverPhotoInitial();
           }

        } else if(mounted) {
           log("ViewModel: Delete cover photo failed (service returned false or component unmounted).");
           state = const CoverPhotoError("Failed to delete cover photo.");
        }

     } catch (e) {
        log("ViewModel: Error during cover photo delete process: $e");
        if (mounted) {
          state = CoverPhotoError("Failed to delete cover photo: ${e.toString()}");
        }
     }
   }

   void showCoverPhotoSourceDialog(BuildContext context) {
     final ProfileState currentMainState = _ref.read(profileViewModelProvider);
     String currentCoverUrl = "";
     if (currentMainState is ProfileLoaded) {
        currentCoverUrl = currentMainState.userProfile.coverPhotoUrl;
     }

     final options = [
        // REMOVED: Take Photo Option
       // ReusableBottomSheetOption(
       //   icon: Icons.camera_alt_outlined,
       //   title: 'Take Photo',
       //   onTap: () {
       //     pickCoverPhoto(ImageSource.camera);
       //   },
       // ),
       ReusableBottomSheetOption(
         icon: Icons.photo_library_outlined,
         title: 'Choose From Gallery',
         onTap: () {
           pickCoverPhoto(ImageSource.gallery);
         },
       ),
        if (currentCoverUrl.isNotEmpty)
          ReusableBottomSheetOption(
             icon: Icons.delete_outline,
             title: 'Delete cover photo',
             onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Cover Photo?'),
                    content: const Text('Are you sure you want to delete your cover photo?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          deleteCoverPhoto();
                        },
                      ),
                    ],
                  ),
                );
             },
          ),
     ];

      showReusableBottomSheet(context: context, options: options);
   }

   void resetState() {
      state = const CoverPhotoInitial();
   }
}

final coverPhotoViewModelProvider =
    StateNotifierProvider.autoDispose<CoverPhotoViewModel, CoverPhotoState>(
        (ref) {
  return CoverPhotoViewModel(ref);
});