import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageCropper {
  final ImagePicker _picker = ImagePicker();

  Future<CroppedFile?> cropImage({required bool isCircle}) async {
    try {
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isCircle ? 512 : 1024,
        maxHeight: isCircle ? 512 : 1024,
      );

      if (imageFile == null) return null;

      final List<PlatformUiSettings> uiSettings = [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(context: null),
      ];

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: isCircle
            ? CropAspectRatio(ratioX: 1, ratioY: 1)
            : null,
        cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
        compressQuality: 90,
        uiSettings: uiSettings,
      );

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      rethrow;
    }
  }
}
