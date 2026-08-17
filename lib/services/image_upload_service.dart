import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_cropper/image_cropper.dart';
import '../services/firestore_service.dart';

class ImageUploadService {
  final firebase_auth.FirebaseAuth _auth;

  ImageUploadService({
    firebase_auth.FirebaseAuth? auth,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  Future<String> uploadImage(CroppedFile imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final userId = user.uid;
      final storage = FirebaseStorage.instance;
      final firestoreService = FirestoreService();

      final ref = storage
          .ref()
          .child('profile_images')
          .child(userId);

      final bytes = await imageFile.readAsBytes();
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      await firestoreService.updateUserImage(userId, downloadUrl);

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String? currentImageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;

    if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      try {
        final storage = FirebaseStorage.instance;
        final ref = storage.refFromURL(currentImageUrl);
        await ref.delete();
      } catch (e) {
        // Ignore deletion errors
      }
    }

    await FirestoreService().updateUserImage(userId, null);
  }
}
