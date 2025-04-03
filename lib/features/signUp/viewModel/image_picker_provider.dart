import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/services/image_picker_service.dart';
import 'package:link_up/features/signUp/viewModel/signup_notifier.dart';
import '../state/image_picker_state.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerServiceProvider = Provider((ref) => ImagePickerService());

final imagePickerProvider =
    StateNotifierProvider<ImagePickerNotifier, ImagePickerState>((ref) {
  final service = ref.watch(imagePickerServiceProvider);
  final signUpNotifier = ref.read(signUpProvider.notifier);
  return ImagePickerNotifier(service, signUpNotifier);
});

class ImagePickerNotifier extends StateNotifier<ImagePickerState> {
  final ImagePickerService _imagePickerService;
  final SignUpNotifier _signUpNotifier;

  ImagePickerNotifier(this._imagePickerService, this._signUpNotifier)
      : super(ImageInitialState());

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePickerService.pickImage(source);
      if (image != null) {
        state = ImageSelectedState(image);
      } else {
        state = ImageErrorState("No image selected");
      }
    } catch (e) {
      state = ImageErrorState("Failed to pick image");
    }
  }

  void showImageSourceDialog(
      BuildContext context, ImagePickerNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                notifier.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                notifier.pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }



}
