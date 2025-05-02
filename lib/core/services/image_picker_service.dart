
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:image_picker/image_picker.dart';


class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
       final pickedFile = await _picker.pickImage(source: source);
       return pickedFile;
    } catch (e) {
       print("Image picking error: $e"); 
       return null; 
    }
  }
}

// Provider for the service
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});