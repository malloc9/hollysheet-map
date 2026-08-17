import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'cropper_preloader.dart';

/// ProfileImageCropper handles image picking and cropping for profile avatars.
///
/// On web platforms, the image is pre-loaded before the cropper dialog
/// to ensure it's ready, avoiding the race condition where the cropper
/// initializes before the image has loaded.
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

      // Pre-load the image to ensure it's cached before cropper initializes
      // This helps avoid "cropper has not been initialized" errors on web
      await preloadImageForCropper(imageFile.path);

      // use_build_context_synchronously
      return await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio:
            isCircle ? CropAspectRatio(ratioX: 1, ratioY: 1) : null,
        compressQuality: 90,
        uiSettings: [
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 500, height: 500),
            dragMode: WebDragMode.crop,
            viewwMode: WebViewMode.mode_1,
            checkCrossOrigin: false,
            checkOrientation: false,
            cropBoxMovable: true,
            cropBoxResizable: true,
            rotatable: true,
            scalable: true,
            zoomable: true,
            modal: true,
            guides: true,
            center: true,
            highlight: true,
            background: true,
            minContainerWidth: 400,
            minContainerHeight: 400,
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
    } catch (e) {
      debugPrint('Error cropping image: $e');
      rethrow;
    }
  }
}