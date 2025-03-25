import 'package:image_picker/image_picker.dart';
import '../model/image_model.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<ImageModel?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return ImageModel(path: pickedFile.path);
    }
    return null;
  }
}
