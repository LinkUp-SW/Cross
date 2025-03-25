import '../model/image_model.dart';

sealed class ImagePickerState {}

class ImageInitialState extends ImagePickerState {}

class ImageSelectedState extends ImagePickerState {
  final ImageModel image;
  ImageSelectedState(this.image);
}

class ImageErrorState extends ImagePickerState {
  final String message;
  ImageErrorState(this.message);
}
