import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageCropper {
  final ImagePicker _picker = ImagePicker();

  Future<CroppedFile?> cropImage({
    required bool isCircle,
    required BuildContext context,
  }) async {
    try {
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isCircle ? 512 : 1024,
        maxHeight: isCircle ? 512 : 1024,
      );

      if (imageFile == null) return null;

      // ignore: use_build_context_synchronously
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: isCircle
            ? CropAspectRatio(ratioX: 1, ratioY: 1)
            : null,
        compressQuality: 90,
        uiSettings: [
          WebUiSettings(
            // ignore: use_build_context_synchronously
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 500, height: 500),
            dragMode: WebDragMode.crop,
            cropBoxMovable: true,
            cropBoxResizable: true,
            rotatable: true,
            scalable: true,
            zoomable: true,
            translations: WebTranslations(
              title: 'Cropper',
              rotateLeftTooltip: 'Rotate Left',
              rotateRightTooltip: 'Rotate Right',
              cancelButton: 'Cancel',
              cropButton: 'Done',
            ),
          ),
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
          ),
          IOSUiSettings(
            title: 'Cropper',
            cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
          ),
        ],
      );

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      rethrow;
    }
  }
}
