import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/services/image_picker_service.dart';
import '../state/image_picker_state.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerServiceProvider = Provider((ref) => ImagePickerService());

final imagePickerProvider =
    StateNotifierProvider<ImagePickerNotifier, ImagePickerState>((ref) {
  final service = ref.watch(imagePickerServiceProvider);
  return ImagePickerNotifier(service);
});

class ImagePickerNotifier extends StateNotifier<ImagePickerState> {
  final ImagePickerService _imagePickerService;

  ImagePickerNotifier(this._imagePickerService) : super(ImageInitialState());

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
}
