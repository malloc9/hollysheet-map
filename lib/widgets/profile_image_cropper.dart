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

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: isCircle
            ? const CropAspectRatio(ratioX: 1, ratioY: 1)
            : null,
        cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
        compressQuality: 90,
        uiSettings: _getUiSettings(isCircle),
      );

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      rethrow;
    }
  }

  UiSettings _getUiSettings(bool isCircle) {
    return const PlatformUiSettings(
      androidInitSettings: AndroidInitSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      iosInitSettings: IOSInitSettings(
        title: 'Cropper',
        aspectRatioPickerFormats: IOSAspectRatioPickerFormats.squareAndRectangle,
        squareAspectRatioName: 'Square',
        rectangleAspectRatioName: 'Rectangle',
      ),
      webInitSettings: WebUiSettings(
        context: null,
      ),
    );
  }
}
